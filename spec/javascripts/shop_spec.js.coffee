window.shopProducts = [
  { id: "e1", name: "elote chico", price: 15.00 },
  { id: "e2", name: "elote mediano", price: 20.00 },
  { id: "e3", name: "elote grande", price: 25.00 }
]

Products =
  findWithId: (products, id) ->
    for product in products when product.id is id
      return product

Order =
  new: (items)->
    items: items or []

  newItem: (product) ->
    productId: product.id
    name: product.name
    count: 1
    total: product.price
    price: product.price

  incrementItemCount: (item) ->
    productId: item.productId
    name: item.name
    count: item.count + 1
    total: item.price * (item.count + 1)
    price: item.price

  findItem: (order, productId) ->
    for item in order.items when item.productId is productId
      return item

  addItem: (order, product) ->
    item = @findItem(order, product.id)
    item = if item then @incrementItemCount(item) else @newItem(product)
    items = order.items.filter((item) -> product.id != item.productId)
    @new(items.concat(item))

window.Shop =
  new: (products, order) ->
    products: products
    currentOrder: order or Order.new()

  addToOrder: (shop, productId) ->
    product = Products.findWithId(shop.products, productId)
    order = Order.addItem(shop.currentOrder, product)
    @new(shop.products, order)

describe "Shop", ->
  it "has the configured options", ->
    shop = Shop.new(shopProducts)
    expect(shop.products).toEqual [
      { id: "e1", name: "elote chico", price: 15.00 },
      { id: "e2", name: "elote mediano", price: 20.00 },
      { id: "e3", name: "elote grande", price: 25.00 }
    ]

  it "can add an item to the order", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.items).toEqual [
      { productId: "e2", name: "elote mediano", count: 1, price: 20.00, total: 20.00 }
    ]

  it "can add the same item more than once", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.items).toEqual [
      { productId: "e2", name: "elote mediano", count: 2, price: 20.00, total: 40.00 }
    ]

  it "can add the different items to the order", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.items).toEqual [
      { productId: "e1", name: "elote chico", count: 1, price: 15.00, total: 15.00 }
      { productId: "e2", name: "elote mediano", count: 1, price: 20.00, total: 20.00 }
    ]
