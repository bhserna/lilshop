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

Actions =
  navTo: (path, fun) ->
    $(document).on "click", "[data-nav=#{path}]", fun

  onAction: (type, name, fun) ->
    $(document).on type, "[data-action=#{name}]", (event) ->
      fun(event, $(this))

{navTo, onAction} = Actions

navTo "products", ->
  App.currentMain = "products"
  App.render()

navTo "currentOrder", ->
  App.currentMain = "currentOrder"
  App.render()

onAction "click", "add-item", (event, $el) ->
  productId = $el.data("id")
  App.shop = Shop.addToOrder(App.shop, productId)
  App.render()

Html =
  render: (currentMain, shop) -> """
  <div class="top-bar">
    <h1>Granito Divino</h1>
    <a class="top-bar__action" href="#">Ordenes de hoy</a>
  </div>

  <ul class="navbar">
    <li><a href="#" data-nav="products">Productos</a>
    <li><a href="#" data-nav="currentOrder">Orden - $#{shop.currentOrder.total}</a>
  </ul>

  <div class="content">
    #{@content(currentMain, shop)}
  </div>
  """

  renderMany: (collection, template) ->
    (template(item) for item in collection).join ""

  content: (currentMain, shop) ->
    pageName = "#{currentMain}Page"
    unless pageName of this
      throw "NoPageError: Page with name #{pageName} is not defined"
    this[pageName](shop)

  productsPage: (shop) -> """
  <div class="product-list">
    #{@renderMany shop.products, @productItem}
  </div>
  """

  currentOrderPage: (shop) -> """
  <div class="order">
    <table>
      <thead>
        <tr>
          <th>Nombre</th>
          <th class="text-center">Cantidad</th>
          <th class="text-center">Total</th>
        </tr>
      </thead>
      <tbody>
        #{@renderMany shop.currentOrder.items, @orderItem}
      </tbody>
    </table>
  </div>

  #{if _.isEmpty(shop.currentOrder.items) then "" else @captureOrderButton()}
  """

  captureOrderButton: -> """
  <div class="order-button">
    <button>Capturar</button>
  </div>
  """

  orderItem: (item) -> """
  <tr>
    <td>#{item.name}</td>
    <td class="text-center">#{item.count}</td>
    <td class="text-center">$#{item.total}</td>
  </tr>
  """

  productItem: (product) -> """
  <div class="product-item" data-action="add-item" data-id=#{product.id}>
    <div class="product-item__body">
      <h1>#{product.name}</h1>
      <span>$#{product.price}</span>
    </div>
  </div>
  """

window.App =
  init: (@$el) ->
    @currentMain = "products"
    @shop = Shop.new(shopProducts)

  render: ->
    @$el.html Html.render(@currentMain, @shop)

$ ->
  App.init $("body")
  App.render()
