window.Html =
  render: (currentMain, shop) ->
    Templates.application(currentMain, shop)

  renderMany: (collection, template) ->
    (template(item) for item in collection).join ""

  renderMain: (currentMain, shop) ->
    pageName = "#{currentMain}Page"
    unless pageName of Templates
      throw "NoPageError: Page with name #{pageName} is not defined"
    Templates[pageName](shop)

window.Actions =
  navTo: (path, fun) ->
    $(document).on "click", "[data-nav=#{path}]", fun

  onAction: (type, name, fun) ->
    $(document).on type, "[data-action=#{name}]", (event) ->
      fun(event, $(this))

{renderMain, renderMany} = Html

Templates =
  application: (currentMain, shop) -> """
    <div class="top-bar">
      <h1>Granito Divino</h1>
      <a class="top-bar__action" href="#">Ordenes de hoy</a>
    </div>

    <ul class="navbar">
      <li><a href="#" data-nav="products">Productos</a>
      <li><a href="#" data-nav="currentOrder">Orden - $#{shop.currentOrder.total}</a>
    </ul>

    <div class="content">
      #{renderMain(currentMain, shop)}
    </div>
  """
  productsPage: (shop) -> """
    <div class="product-list">
      #{renderMany shop.products, @productItem}
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
          #{renderMany shop.currentOrder.items, @orderItem}
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
    <div class="product-item" data-action="addItem" data-id=#{product.id}>
      <div class="product-item__body">
        <h1>#{product.name}</h1>
        <span>$#{product.price}</span>
      </div>
    </div>
  """
