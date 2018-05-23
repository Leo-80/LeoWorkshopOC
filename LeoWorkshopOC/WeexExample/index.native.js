// { "framework": "Vue" }

(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define([], factory);
	else if(typeof exports === 'object')
		exports["npm/stgpk-weex/src/test/index"] = factory();
	else
		root["npm/stgpk-weex/src/test/index"] = factory();
})(this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 68);
/******/ })
/************************************************************************/
/******/ ({

/***/ 109:
/***/ (function(module, exports) {

module.exports = {
  "main": {
    "width": "750",
    "height": "1340",
    "paddingTop": "100"
  },
  "main-content": {
    "alignItems": "center",
    "justifyContent": "center"
  },
  "bannerimg": {
    "width": "100",
    "height": "100"
  },
  "main-text": {
    "borderWidth": "4",
    "borderColor": "#A52A2A",
    "marginTop": "50",
    "marginRight": "20",
    "marginBottom": "50",
    "marginLeft": "20"
  },
  "main-text2": {
    "borderWidth": "4",
    "borderColor": "#FFFF00",
    "marginTop": "50",
    "marginRight": "20",
    "marginBottom": "50",
    "marginLeft": "20"
  },
  "gifimage": {
    "width": "75",
    "height": "75"
  }
}

/***/ }),

/***/ 131:
/***/ (function(module, exports) {

module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: ["main"],
    on: {
      "viewappear": _vm.onviewappear,
      "viewdisappear": _vm.onviewdisappear
    }
  }, [_c('text', {
    staticClass: ["main-text"],
    on: {
      "click": function($event) {
        _vm.getgobaltoken()
      }
    }
  }, [_vm._v("weex调用native 同步方法 getgobaltoken")]), _c('text', {
    staticClass: ["main-text"],
    on: {
      "click": function($event) {
        _vm.gotomyter()
      }
    }
  }, [_vm._v("weex调用native gotomyter")]), _c('text', {
    staticClass: ["main-text"],
    on: {
      "click": function($event) {
        _vm.gotoString()
      }
    }
  }, [_vm._v("weex调用native gotoString")]), _c('text', {
    staticClass: ["main-text"],
    on: {
      "click": function($event) {
        _vm.showToast()
      }
    }
  }, [_vm._v("showToast")]), _c('text', {
    staticClass: ["main-text2"]
  }, [_vm._v(_vm._s(_vm.result))]), _c('div', {
    staticClass: ["main-content"]
  }, [_c('image', {
    staticClass: ["bannerimg"],
    attrs: {
      "src": _vm.bannerone
    }
  })]), _c('gifimage', {
    ref: "mycomponent",
    staticClass: ["gifimage"]
  })], 1)
},staticRenderFns: []}
module.exports.render._withStripped = true

/***/ }),

/***/ 41:
/***/ (function(module, exports, __webpack_require__) {

var __vue_exports__, __vue_options__
var __vue_styles__ = []

/* styles */
__vue_styles__.push(__webpack_require__(109)
)

/* script */
__vue_exports__ = __webpack_require__(97)

/* template */
var __vue_template__ = __webpack_require__(131)
__vue_options__ = __vue_exports__ = __vue_exports__ || {}
if (
  typeof __vue_exports__.default === "object" ||
  typeof __vue_exports__.default === "function"
) {
if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
__vue_options__ = __vue_exports__ = __vue_exports__.default
}
if (typeof __vue_options__ === "function") {
  __vue_options__ = __vue_options__.options
}
__vue_options__.__file = "/Users/james/Documents/innotech/stgpk-weex/src/test/test.vue"
__vue_options__.render = __vue_template__.render
__vue_options__.staticRenderFns = __vue_template__.staticRenderFns
__vue_options__._scopeId = "data-v-295a50aa"
__vue_options__.style = __vue_options__.style || {}
__vue_styles__.forEach(function (module) {
  for (var name in module) {
    __vue_options__.style[name] = module[name]
  }
})
if (typeof __register_static_styles__ === "function") {
  __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
}

module.exports = __vue_exports__


/***/ }),

/***/ 68:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _test = __webpack_require__(41);

var _test2 = _interopRequireDefault(_test);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

_test2.default.el = '#root';
exports.default = new Vue(_test2.default);

/***/ }),

/***/ 97:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//


var modal = weex.requireModule('modal');
var globalEvent = weex.requireModule('globalEvent');
var NativeRouter = weex.requireModule('weexToNative'); // 和native的跳转路由

exports.default = {
    data: function data() {
        return {
            result: '',
            bannerone: 'https://itest.jw830.com/activity/stgpk-weex/img/home_invite_bg@2x.png?a=180414'
        };
    },
    created: function created() {
        modal.toast({ message: 'page created', duration: 2 });
    },
    mounted: function mounted() {

        modal.toast({ message: 'page mounted', duration: 2 });

        // 初始化时监听
        // 1、native 主动调用 weex  
        // EventKey：nativeToweex  
        // Params: {@"params":@"this is params"}
        var that = this;
        globalEvent.addEventListener("nativeToweex", function (e) {
            modal.toast({ message: 'nativeToweex, params: ' + JSON.stringify(e), duration: 2 });
            that.result = "nativeToweex params:" + JSON.stringify(e);
        });

        this.$refs.mycomponent.getGifURL('https://itest.jw830.com/activity/stgpk-weex/img/ad/gif.gif');
    },

    methods: {
        onviewappear: function onviewappear() {
            modal.toast({ message: 'page onviewappear', duration: 2 });
            this.result = "page onviewappear";
        },
        onviewdisappear: function onviewdisappear() {
            modal.toast({ message: 'page onviewdisappear', duration: 2 });
            this.result = "page onviewdisappear";
        },
        getgobaltoken: function getgobaltoken() {
            var that = this;
            NativeRouter.getgobaltoken("getgobaltoken", function (e) {
                modal.toast({ message: 'weexToNative: getgobaltoken params: ' + e, duration: 2 });
                that.result = "getgobaltoken params:" + e;
            });
        },
        gotomyter: function gotomyter() {
            NativeRouter.gotomyter('weex \u8C03\u7528 native gotomyter');
            this.result = "gotomyter";
        },
        gotoString: function gotoString() {
            NativeRouter.gotoString('weex 调用 native gotoString');
            this.result = "gotoString";
        },
        showToast: function showToast() {
            this.result = "showToast";
            console.log('will show toast');
            modal.toast({
                message: 'This is a toast',
                duration: 2
            });
        }
    }
};

/***/ })

/******/ });
});
//# sourceMappingURL=index.native.js.map