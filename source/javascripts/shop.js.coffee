# require html

Dict =
  update: (object, props) ->
    _.extend {}, object, props

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
  new: (items) ->
    items: Item.sort(items) or []
    total: _.reduce items, ((acc, item) -> acc + item.total), 0

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

window.Shop =
  new: (products, order, currentPage) ->
    products: products
    currentOrder: order or Order.new()
    currentPage: currentPage or "products"

  changePage: (shop, page) ->
    @update shop, currentPage: page

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

  updateCurrentOrder: (shop, order) ->
    @update shop, currentOrder: order

  update: (shop, props) ->
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
  App.update Shop.changePage(shop, page)

onAction "click", "addItem", (shop, $el) ->
  productId = $el.data("id")
  App.update Shop.addToOrder(shop, productId)

onAction "click", "incrementCount", (shop, $el) ->
  productId = $el.data("id")
  App.update Shop.incrementCountInOrder(shop, productId)

onAction "click", "decrementCount", (shop, $el) ->
  productId = $el.data("id")
  App.update Shop.decrementCountInOrder(shop, productId)

$ ->
  App.init $(".js-app"), Shop.new(shopProducts)
  App.render()
