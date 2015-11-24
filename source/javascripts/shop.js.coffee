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

  update: (item, props) ->
    _.extend {}, item, props

Products =
  findWithId: (products, id) ->
    for product in products when product.id is id
      return product

Order =
  new: (items) ->
    items: items or []
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

window.ShopNavigation =
  init: ->
    currentMain: "products"

  goToCurrentOrder: (nav) ->
    currentMain: "currentOrder"

  goToTodayOrders: (nav) ->
    currentMain: "todayOrders"

window.Shop =
  new: (products, order) ->
    products: products
    currentOrder: order or Order.new()

  addToOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.addItem(shop.currentOrder, product)
    @new(shop.products, order)

  incrementCountInOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.incrementCount(shop.currentOrder, product)
    @new(shop.products, order)

  decrementCountInOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.decrementCount(shop.currentOrder, product)
    @new(shop.products, order)

shopProducts = [
  { id: "e1", name: "Elote chico", price: 15.00 },
  { id: "e2", name: "Elote mediano", price: 20.00 },
  { id: "e3", name: "Elote grande", price: 25.00 }
  { id: "e4", name: "Conchitas", price: 25.00 }
  { id: "e5", name: "Tostitos", price: 30.00 }
]

window.App =
  init: ->
    @nav = ShopNavigation.init()
    @shop = Shop.new(shopProducts)

  render: ($el) ->
    $el.html @renderHtml(@nav, @shop)

  renderHtml: (nav, shop) -> """
  <div class="top-bar">
    <h1>Granito Divino</h1>
    <a class="top-bar__action" href="#">Ordenes de hoy</a>
  </div>

  <ul class="navbar">
    <li><a href="#">Productos</a>
    <li><a href="#">Orden - $#{shop.currentOrder.total}</a>
  </ul>

  <div class="content">
    #{@contentHtml(nav, shop)}
  </div>
  """

  contentHtml: (nav, shop) ->
    this["#{nav.currentMain}PageHtml"](shop)

  productsPageHtml: (shop) -> """
  <div class="product-list">
    #{(@productItemHtml(product) for product in shop.products).join ""}
  </div>
  """

  productItemHtml: (product) -> """
  <div class="product-item">
    <div class="product-item__body">
      <h1>#{product.name}</h1>
      <span>$#{product.price}</span>
    </div>
  </div>
  """

$ ->
  App.init()
  App.render $("body")
