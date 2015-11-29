window.Html =
  render: (shop) ->
    Templates.application(shop)

  renderMany: (collection, template) ->
    (template(item) for item in collection).join ""

  renderMain: (shop) ->
    pageName = "#{shop.currentPage}Page"
    unless pageName of Templates
      throw "NoPageError: Page with name #{pageName} is not defined"
    Templates[pageName](shop)

  renderIf: (condition, renderable) ->
    if condition then renderable() else ""

  renderUnless: (condition, renderable) ->
    if condition then "" else renderable()

window.Actions =
  navTo: (path, fun) ->
    $(document).on "click", "[data-nav=#{path}]", fun

  onAction: (type, name, fun) ->
    $(document).on type, "[data-action=#{name}]", (event) ->
      fun(event, $(this))

{renderMain, renderMany, renderIf, renderUnless} = Html

Templates =
  application: (shop) -> """
    <div class="top-bar">
      <h1>Granito Divino</h1>
      <a class="top-bar__action" href="#">Ordenes de hoy</a>
    </div>

    <ul class="navbar">
      <li><a href="#" data-nav="products">Productos</a>
      <li><a href="#" data-nav="currentOrder">Orden - $#{shop.currentOrder.total}</a>
    </ul>

    <div class="content">
      #{renderMain(shop)}
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
            <th></th>
            <th class="order__count-column">Cantidad</th>
            <th class="order__total-column">Total</th>
          </tr>
        </thead>
        <tbody>
          #{renderMany shop.currentOrder.items, @orderItem}

          <tr>
            <td></td>
            <td class="order__count-column"><strong>Total:</strong></td>
            <td class="order__total-column">$#{shop.currentOrder.total}</td>
          </tr>

          #{renderUnless _.isEmpty(shop.currentOrder.items), @captureOrderButton}
        </tbody>
      </table>
    </div>
  """

  captureOrderButton: -> """
    <tr>
      <td colspan="3" class="text-center">
        <div class="order__buttons">
          <button class="order__cancel-button">Cancelar</button>
          <button>Capturar</button>
        </div>
      </td>
    </tr>
  """

  orderItem: (item) -> """
    <tr>
      <td>#{item.name}</td>
      <td class="order__count-column">
        <button data-action="decrementCount" data-id="#{item.productId}">
          <span class="fa fa-minus"></span>
        </button>
        <span class="order__item-count">#{item.count}</span>
        <button data-action="incrementCount" data-id="#{item.productId}">
          <span class="fa fa-plus"></span>
        </button>
      </td>
      <td class="order__total-column">$#{item.total}</td>
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
