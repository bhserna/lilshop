(function() {
  var Templates, renderIf, renderMain, renderMany, renderUnless;

  window.Html = {
    render: function(shop) {
      return Templates.application(shop);
    },
    renderMany: function(collection, template) {
      var item;
      return ((function() {
        var i, len, results;
        results = [];
        for (i = 0, len = collection.length; i < len; i++) {
          item = collection[i];
          results.push(template(item));
        }
        return results;
      })()).join("");
    },
    renderMain: function(shop) {
      var pageName;
      pageName = shop.currentPage + "Page";
      if (!(pageName in Templates)) {
        throw "NoPageError: Page with name " + pageName + " is not defined";
      }
      return Templates[pageName](shop);
    },
    renderIf: function(condition, renderable) {
      if (condition) {
        return renderable();
      } else {
        return "";
      }
    },
    renderUnless: function(condition, renderable) {
      if (condition) {
        return "";
      } else {
        return renderable();
      }
    }
  };

  window.App = {
    init: function($el, shop1) {
      this.$el = $el;
      this.shop = shop1;
    },
    render: function() {
      return this.$el.html(Html.render(this.shop));
    },
    update: function(shop) {
      this.shop = shop;
      return this.render();
    }
  };

  window.Actions = {
    onAction: function(type, name, fun) {
      return $(document).on(type, "[data-action=" + name + "]", function(event) {
        return fun(App.shop, $(this));
      });
    }
  };

  renderMain = Html.renderMain, renderMany = Html.renderMany, renderIf = Html.renderIf, renderUnless = Html.renderUnless;

  Templates = {
    application: function(shop) {
      return "<div class=\"top-bar\">\n  <h1>Lilshop</h1>\n  <a class=\"top-bar__action\" href=\"#\" data-action=\"navigateTo\" data-page=\"capturedOrders\">\n    Captured orders\n  </a>\n</div>\n\n<ul class=\"navbar\">\n  <li>\n    <a href=\"#\" data-action=\"navigateTo\" data-page=\"products\">\n      Products\n    </a>\n  </li>\n  <li>\n    <a href=\"#\"\n      " + (shop.currentOrder.isFlashed ? "class='flashy'" : void 0) + "}\n      data-action=\"navigateTo\"\n      data-page=\"currentOrder\">\n      Order - $" + shop.currentOrder.total + "\n    </a>\n  </li>\n</ul>\n\n<div class=\"content\">\n  " + (renderMain(shop)) + "\n</div>";
    },
    productsPage: function(shop) {
      return "<div class=\"product-list\">\n  " + (renderMany(shop.products, this.productItem)) + "\n</div>";
    },
    capturedOrdersPage: function(shop) {
      return "<ul>\n  " + (renderMany(shop.capturedOrders, this.capturedOrder)) + "\n</ul>";
    },
    capturedOrder: function(order) {
      return "<li class=\"captured-order\">\n  <span>" + (moment(order.capturedAt).format("ddd, h:mm a")) + "</span>\n  <strong class=\"pull-right\">$" + order.total + "</strong>\n</li>";
    },
    currentOrderPage: function(shop) {
      return "<div class=\"order\">\n  <table>\n    <thead>\n      <tr>\n        <th>Producto</th>\n        <th class=\"order__count-column\">Cantidad</th>\n        <th class=\"order__total-column\">Total</th>\n      </tr>\n    </thead>\n    <tbody>\n      " + (renderMany(shop.currentOrder.items, this.orderItem)) + "\n\n      <tr>\n        <td></td>\n        <td class=\"order__count-column\"><strong>Total:</strong></td>\n        <td class=\"order__total-column " + (shop.currentOrder.isFlashed ? "flashy" : void 0) + "\">\n          $" + shop.currentOrder.total + "\n        </td>\n      </tr>\n\n      " + (renderIf(shop.currentOrder.canBeCaptured, this.orderButtons)) + "\n    </tbody>\n  </table>\n</div>";
    },
    orderButtons: function() {
      return "<tr>\n  <td colspan=\"3\" class=\"text-center\">\n    <div class=\"order__buttons\">\n      <button class=\"order__cancel-button\" data-action=\"cancelOrder\">\n        Cancelar\n      </button>\n      <button data-action=\"captureOrder\">\n        Capturar\n      </button>\n    </div>\n  </td>\n</tr>";
    },
    orderItem: function(item) {
      return "<tr>\n  <td>" + item.name + "</td>\n  <td class=\"order__count-column\">\n    <button data-action=\"decrementCount\" data-id=\"" + item.productId + "\">\n      <span class=\"fa fa-minus\"></span>\n    </button>\n    <span class=\"order__item-count\">" + item.count + "</span>\n    <button data-action=\"incrementCount\" data-id=\"" + item.productId + "\">\n      <span class=\"fa fa-plus\"></span>\n    </button>\n  </td>\n  <td class=\"order__total-column\">$" + item.total + "</td>\n</tr>";
    },
    productItem: function(product) {
      return "<button class=\"product-item\" data-action=\"addItem\" data-id=" + product.id + ">\n  <div class=\"product-item__body\">\n    <h1>" + product.name + "</h1>\n    <span>$" + product.price + "</span>\n  </div>\n</button>";
    }
  };

}).call(this);
