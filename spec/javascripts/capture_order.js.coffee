shopProducts = [
  { id: "e1", name: "elote chico", price: 15.00 },
  { id: "e2", name: "elote mediano", price: 20.00 },
  { id: "e3", name: "elote grande", price: 25.00 }
]

describe "Capture order", ->
  it "the order cannot be captured if has no items", ->
    shop = Shop.new(shopProducts)
    expect(shop.currentOrder.canBeCaptured).toBeFalsy()

  it "the order can be captured if has the items", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.canBeCaptured).toBeTruthy()

  it "resets the current order", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.captureOrder(shop)
    expect(shop.currentOrder.items).toEqual []

  it "adds the current order to the captured orders", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    order = shop.currentOrder
    shop = Shop.captureOrder(shop)
    captureOrder = _.first shop.capturedOrders
    expect(captureOrder.items).toEqual order.items

  it "can add several orders", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.captureOrder(shop)

    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.captureOrder(shop)

    expect(shop.capturedOrders.length).toEqual 2

  it "captures the date current date", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.captureOrder(shop)
    capturedOrder = _.first shop.capturedOrders
    expect(capturedOrder.capturedAt).toEqual Time.now()

  it "gives the order an id", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.captureOrder(shop)
    capturedOrder = _.first shop.capturedOrders
    expect(capturedOrder.id).toEqual 1

  it "increments the id", ->
    shop = Shop.new(shopProducts)

    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.captureOrder(shop)
    capturedOrder = _.first shop.capturedOrders
    expect(capturedOrder.id).toEqual 1

    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.captureOrder(shop)
    capturedOrder = _.first shop.capturedOrders
    expect(capturedOrder.id).toEqual 2
