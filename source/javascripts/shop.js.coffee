# require html

Dict =
  update: (object, props) ->
    _.extend {}, object, props

window.Time =
  now: -> moment().format()
  utc: -> moment.utc().format()

LocalStore =
 save: (state) ->
   localStorage.shop = JSON.stringify(state)

 load: ->
   JSON.parse(localStorage.shop || "{}")

Item =
  haveSameProduct: (item1, item2) ->
    item1.productId is item2.productId

  newFromProduct: (product) ->
    productId: product.id
    name: product.name
    count: 1
    total: product.price
    price: product.price

  incrementCount: (item) ->
    count = item.count + 1
    @update item,
      count: count
      total: item.price * count

  decrementCount: (item) ->
    count = item.count - 1
    @update item,
      count: count
      total: item.price * count

  sort: (items) ->
    _.sortBy items, "productId"

  update: (item, props) ->
    Dict.update item, props

Products =
  findWithId: (products, id) ->
    for product in products when product.id is id
      return product

Order =
  new: (items = [], options = {}) ->
    id: options.id or null
    items: Item.sort(items)
    total: _.reduce items, ((acc, item) -> acc + item.total), 0
    canBeCaptured: _.some(items)
    isFlashed: options.isFlashed or false
    capturedAt: options.capturedAt or null

  flashTotal: (order) ->
    @new(order.items, isFlashed: true)

  resetFlashes: (order) ->
    @new(order.items, isFlashed: false)

  findItem: (order, productId) ->
    _.findWhere order.items, productId: productId

  insertItem: (order, itemToInsert) ->
    items = _.filter order.items, (item) -> not Item.haveSameProduct(itemToInsert, item)
    @new(items.concat(itemToInsert))

  removeItem: (order, itemToInsert) ->
    items = _.filter order.items, (item) -> not Item.haveSameProduct(itemToInsert, item)
    @new(items)

  addItem: (order, product) ->
    item = @findItem(order, product.id)
    item = if item then Item.incrementCount(item) else Item.newFromProduct(product)
    @insertItem(order, item)

  incrementCount: (order, product) ->
    item = @findItem(order, product.id)
    item = Item.incrementCount(item)
    @insertItem(order, item)

  decrementCount: (order, product) ->
    item = @findItem(order, product.id)
    item = Item.decrementCount(item)
    if item.count is 0 then @removeItem(order, item) else @insertItem(order, item)

  capture: (order, nextOrderId) ->
    @new(order.items, id: nextOrderId, capturedAt: Time.now())

  sort: (orders) ->
    _.sortBy(orders, "id").reverse()

window.Shop =
  new: (products, order, currentPage) ->
    products: products
    currentOrder: order or Order.new()
    capturedOrders: []
    currentPage: currentPage or "products"
    nextOrderId: 1

  changePage: (shop, page) ->
    @update shop, currentPage: page

  cancelOrder: (shop) ->
    @updateCurrentOrder shop, Order.new()

  addToOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.addItem(shop.currentOrder, product)
    @updateCurrentOrder(shop, order)

  incrementCountInOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.incrementCount(shop.currentOrder, product)
    @updateCurrentOrder(shop, order)

  decrementCountInOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.decrementCount(shop.currentOrder, product)
    @updateCurrentOrder(shop, order)

  captureOrder: (shop) ->
    order = Order.capture(shop.currentOrder, shop.nextOrderId)
    @update shop,
      nextOrderId: shop.nextOrderId + 1,
      capturedOrders: Order.sort(shop.capturedOrders.concat(order))
      currentOrder: Order.new()

  updateCurrentOrder: (shop, order) ->
    @update shop, currentOrder: Order.flashTotal(order)

  update: (shop, props) ->
    unless props.currentOrder
      order = Order.resetFlashes(shop.currentOrder)
      props = Dict.update(props, currentOrder: order)

    Dict.update(shop, props)

shopProducts = [
  { id: "e1", name: "Elote chico", price: 15.00 },
  { id: "e2", name: "Elote mediano", price: 20.00 },
  { id: "e3", name: "Elote grande", price: 25.00 }
  { id: "e4", name: "Conchitas", price: 25.00 }
  { id: "e5", name: "Tostitos", price: 30.00 }
]

{onAction} = Actions

onAction "click", "navigateTo", (shop, $el) ->
  page = $el.data("page")
  updateState Shop.changePage(shop, page)

onAction "click", "addItem", (shop, $el) ->
  productId = $el.data("id")
  updateState Shop.addToOrder(shop, productId)

onAction "click", "incrementCount", (shop, $el) ->
  productId = $el.data("id")
  updateState Shop.incrementCountInOrder(shop, productId)

onAction "click", "decrementCount", (shop, $el) ->
  productId = $el.data("id")
  updateState Shop.decrementCountInOrder(shop, productId)

onAction "click", "cancelOrder", (shop) ->
  updateState Shop.cancelOrder(shop)

onAction "click", "captureOrder", (shop) ->
  updateState Shop.captureOrder(shop)

updateState = (shop) ->
  App.update(shop)
  LocalStore.save(shop)

loadState = ->
  if _.isEmpty shop = LocalStore.load()
    Shop.new(shopProducts)
  else
    shop

$ ->
  App.init $(".js-app"), loadState()
  App.render()
