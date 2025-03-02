// tailwindcss/lib/util/flattenColorPalette@4.0.9 downloaded from https://ga.jspm.io/npm:tailwindcss@4.0.9/dist/flatten-color-palette.js

var e={};function l(e){let t={};for(let[_,f]of Object.entries(e??{}))if(_!=="__CSS_VALUES__")if(typeof f=="object"&&f!==null)for(let[e,r]of Object.entries(l(f)))t[`${_}${e==="DEFAULT"?"":`-${e}`}`]=r;else t[_]=f;if("__CSS_VALUES__"in e)for(let[_,f]of Object.entries(e.__CSS_VALUES__))Number(f)&4||(t[_]=e[_]);return t}e=l;var t=e;export{t as default};

