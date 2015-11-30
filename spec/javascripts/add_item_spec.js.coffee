shopProducts = [
  { id: "e1", name: "elote chico", price: 15.00 },
  { id: "e2", name: "elote mediano", price: 20.00 },
  { id: "e3", name: "elote grande", price: 25.00 }
]

describe "Add item", ->
  addItem = (shop, productId) ->
    shop = Shop.addToOrder(shop, productId)
    item = _.first shop.currentOrder.items

  it "registers the product id", ->
    shop = Shop.new(shopProducts)
    item = addItem shop, "e2"
    expect(item.productId).toEqual "e2"

  it "registers the product name", ->
    shop = Shop.new(shopProducts)
    item = addItem shop, "e2"
    expect(item.name).toEqual "elote mediano"

  it "registers the product price", ->
    shop = Shop.new(shopProducts)
    item = addItem shop, "e3"
    expect(item.price).toEqual 25.00

  it "starts with a count of one", ->
    shop = Shop.new(shopProducts)
    item = addItem shop, "e2"
    expect(item.count).toEqual 1

  it "calculates the right total", ->
    shop = Shop.new(shopProducts)
    item = addItem shop, "e1"
    expect(item.total).toEqual 15.00

  it "calculates the right order total", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.total).toEqual 20.00

  it "more than once, register just one item", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.items.length).toEqual 1

  it "more than once, adds one to the count", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    item = addItem shop, "e1"
    expect(item.count).toEqual 2

  it "more than once, recalculates the total", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    item = addItem shop, "e1"
    expect(item.total).toEqual 30.00

  it "more than once, calculates the right order total", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.addToOrder(shop, "e1")
    expect(shop.currentOrder.total).toEqual 30.00

  it "and then other item, register two items", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.items.length).toEqual 2

  it "and then other item, calculates the right order total", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.total).toEqual 35.00

  it "flashes the current order total", ->
    shop = Shop.new(shopProducts)
    expect(shop.currentOrder.isFlashed).toBeFalsy()

    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.isFlashed).toBeTruthy()
