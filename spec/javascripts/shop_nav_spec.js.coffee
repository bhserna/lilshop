shopProducts = [
  { id: "e1", name: "elote chico", price: 15.00 },
  { id: "e2", name: "elote mediano", price: 20.00 },
  { id: "e3", name: "elote grande", price: 25.00 }
]

describe "Shop navigation", ->
  it "shows products by default", ->
    shop = Shop.new()
    expect(shop.currentPage).toEqual "products"

  it "can go to the current order", ->
    shop = Shop.new()
    shop = Shop.changePage(shop, "currentOrder")
    expect(shop.currentPage).toEqual "currentOrder"

  it "can go to the order", ->
    shop = Shop.new()
    shop = Shop.changePage(shop, "todayOrders")
    expect(shop.currentPage).toEqual "todayOrders"

  it "should not the order flash", ->
    shop = Shop.new(shopProducts)
    expect(shop.currentOrder.isFlashed).toBeFalsy()

    shop = Shop.addToOrder(shop, "e2")
    expect(shop.currentOrder.isFlashed).toBeTruthy()

    shop = Shop.changePage(shop, "currentOrder")
    expect(shop.currentOrder.isFlashed).toBeFalsy()
