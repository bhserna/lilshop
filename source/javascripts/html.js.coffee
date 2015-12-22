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

window.App =
  init: (@$el, @shop) ->

  render: ->
    @$el.html Html.render(@shop)

  update: (shop) ->
    @shop = shop
    @render()

window.Actions =
  onAction: (type, name, fun) ->
    $(document).on type, "[data-action=#{name}]", (event) ->
      fun App.shop, $(this)

{renderMain, renderMany, renderIf, renderUnless} = Html

Templates =
  application: (shop) -> """
    <div class="top-bar">
      <h1>Lilshop</h1>
      <a class="top-bar__action" href="#" data-action="navigateTo" data-page="capturedOrders">
        Captured orders
      </a>
    </div>

    <ul class="navbar">
      <li>
        <a href="#" data-action="navigateTo" data-page="products">
          Products
        </a>
      </li>
      <li>
        <a href="#"
          #{"class='flashy'" if shop.currentOrder.isFlashed}}
          data-action="navigateTo"
          data-page="currentOrder">
          Order - $#{shop.currentOrder.total}
        </a>
      </li>
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

  capturedOrdersPage: (shop) -> """
    <ul>
      #{renderMany shop.capturedOrders, @capturedOrder}
    </ul>
  """

  capturedOrder: (order) -> """
    <li class="captured-order">
      <span>#{moment(order.capturedAt).format("ddd, h:mm a")}</span>
      <strong class="pull-right">$#{order.total}</strong>
    </li>
  """

  currentOrderPage: (shop) -> """
    <div class="order">
      <table>
        <thead>
          <tr>
            <th>Producto</th>
            <th class="order__count-column">Cantidad</th>
            <th class="order__total-column">Total</th>
          </tr>
        </thead>
        <tbody>
          #{renderMany shop.currentOrder.items, @orderItem}

          <tr>
            <td></td>
            <td class="order__count-column"><strong>Total:</strong></td>
            <td class="order__total-column #{"flashy" if shop.currentOrder.isFlashed}">
              $#{shop.currentOrder.total}
            </td>
          </tr>

          #{renderIf shop.currentOrder.canBeCaptured, @orderButtons}
        </tbody>
      </table>
    </div>
  """

  orderButtons: -> """
    <tr>
      <td colspan="3" class="text-center">
        <div class="order__buttons">
          <button class="order__cancel-button" data-action="cancelOrder">
            Cancelar
          </button>
          <button data-action="captureOrder">
            Capturar
          </button>
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
    <button class="product-item" data-action="addItem" data-id=#{product.id}>
      <div class="product-item__body">
        <h1>#{product.name}</h1>
        <span>$#{product.price}</span>
      </div>
    </button>
  """
