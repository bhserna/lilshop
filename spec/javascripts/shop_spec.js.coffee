shopProducts = [
  { id: "e1", name: "elote chico", price: 15.00 },
  { id: "e2", name: "elote mediano", price: 20.00 },
  { id: "e3", name: "elote grande", price: 25.00 }
]

describe "Shop", ->
  it "has the configured options", ->
    shop = Shop.new(shopProducts)
    expect(shop.products).toEqual [
      { id: "e1", name: "elote chico", price: 15.00 },
      { id: "e2", name: "elote mediano", price: 20.00 },
      { id: "e3", name: "elote grande", price: 25.00 }
    ]

  it "has an initial total of 0", ->
    shop = Shop.new(shopProducts)
    expect(shop.currentOrder.total).toEqual 0.00

  it "can recovers the state of the current order", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.total).toEqual 35.00
    expect(shop.currentOrder.items).toEqual [
      { productId: "e1", name: "elote chico", count: 1, price: 15.00, total: 15.00 }
      { productId: "e2", name: "elote mediano", count: 1, price: 20.00, total: 20.00 }
    ]

    newShop = Shop.new(shopProducts, shop.currentOrder)
    expect(newShop.currentOrder.total).toEqual 35.00
    expect(newShop.currentOrder.items).toEqual [
      { productId: "e1", name: "elote chico", count: 1, price: 15.00, total: 15.00 }
      { productId: "e2", name: "elote mediano", count: 1, price: 20.00, total: 20.00 }
    ]
