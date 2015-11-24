describe "Shop navigation", ->
  it "shows products by default", ->
    nav = ShopNavigation.init()
    expect(nav.currentMain).toEqual "products"

  it "can go to the current order", ->
    nav = ShopNavigation.init()
    nav = ShopNavigation.goToCurrentOrder(nav)
    expect(nav.currentMain).toEqual "currentOrder"

  it "can go to the order", ->
    nav = ShopNavigation.init()
    nav = ShopNavigation.goToTodayOrders(nav)
    expect(nav.currentMain).toEqual "todayOrders"
