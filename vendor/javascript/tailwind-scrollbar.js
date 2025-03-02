// tailwind-scrollbar@4.0.1 downloaded from https://ga.jspm.io/npm:tailwind-scrollbar@4.0.1/src/index.js

import*as r from"tailwindcss/plugin";import*as t from"tailwindcss/lib/util/flattenColorPalette";var a={};
/**
 * @typedef {object} TailwindPlugin
 * @property {Function} matchUtilities - Adds utilities to tailwind
 * @property {Function} theme - Accesses tailwind's theme
 * @property {Function} addVariant - Adds a variant to tailwind
 * @property {Function} config - Accesses tailwind's configuration
 */a.unused={};var l={};
/**
 * Gets the underlying default import of a module.
 *
 * This is used to handle internal imoprts from Tailwind, since Tailwind Play
 * handles these imports differently.
 *
 * @template T
 * @param {T | { __esModule: unknown, default: T }} mod The module
 * @returns {T} The bare export
 */const importDefault$1=r=>r&&r.__esModule?r.default:r;l={importDefault:importDefault$1};var e=l;var o=t;try{"default"in t&&(o=t.default)}catch(r){}var s={};const i=o;const{importDefault:c}=e;const d=c(i);const n=["track","thumb","corner"];
/**
 * @param {Record<never, unknown>} properties - The properties to assign
 * @param {boolean} preferPseudoElements - If true, only browsers that cannot
 *    use pseudoelements will specify scrollbar properties
 * @returns {Record<string, unknown>} - The generated CSS rules
 */const scrollbarProperties=(r,t)=>t?{"@supports (-moz-appearance:none)":r}:r;
/**
 * Base resets to make the plugin's utilities work
 *
 * @param {typedefs.TailwindPlugin} tailwind - Tailwind's plugin object
 * @param {'standard' | 'peseudoelements'} preferredStrategy - The preferred
 *    scrollbar styling strategy: standards track or pseudoelements
 */const addBaseStyles$1=({addBase:r},t)=>{r({"*":scrollbarProperties({"scrollbar-color":"initial","scrollbar-width":"initial"},t==="pseudoelements")})};
/**
 * Generates utilties that tell an element what to do with
 * --scrollbar-track and --scrollbar-thumb custom properties
 *
 * @returns {Record<string, unknown>} - The generated CSS
 */const generateBaseUtilities=()=>({...Object.fromEntries(n.map((r=>{const t=`&::-webkit-scrollbar-${r}`;return[[t,{"background-color":`var(--scrollbar-${r})`,"border-radius":`var(--scrollbar-${r}-radius)`}]]})).flat())})
/**
 * Utilities for initializing a custom styled scrollbar, which implicitly set
 * the scrollbar's size
 *
 * @param {object} options - Options
 * @param {boolean} options.preferPseudoElements - If true, only browsers that
 *    cannot use pseudoelements will specify scrollbar-width
 * @returns {Record<string, unknown>} - Base size utilities for scrollbars
 */;const generateScrollbarSizeUtilities=({preferPseudoElements:r})=>({".scrollbar":{...generateBaseUtilities(),...scrollbarProperties({"scrollbar-width":"auto","scrollbar-color":"var(--scrollbar-thumb, initial) var(--scrollbar-track, initial)"},r),"&::-webkit-scrollbar":{display:"block",width:"var(--scrollbar-width, 16px)",height:"var(--scrollbar-height, 16px)"}},".scrollbar-thin":{...generateBaseUtilities(),...scrollbarProperties({"scrollbar-width":"thin","scrollbar-color":"var(--scrollbar-thumb, initial) var(--scrollbar-track, initial)"},r),"&::-webkit-scrollbar":{display:"block",width:"8px",height:"8px"}},".scrollbar-none":{...scrollbarProperties({"scrollbar-width":"none"},r),"&::-webkit-scrollbar":{display:"none"}}})
/**
 * Converts a color value or function to a color value
 *
 * @param {string | Function} maybeFunction - The color value or function
 * @returns {string} - The color value
 */;const toColorValue=r=>typeof r==="function"?r({}):r
/**
 * Adds scrollbar-COMPONENT-COLOR utilities for every scrollbar component.
 *
 * @param {typedefs.TailwindPlugin} tailwind - Tailwind's plugin object
 */;const addColorUtilities$1=({matchUtilities:r,theme:t})=>{const a=d(t("colors"));const l=Object.fromEntries(Object.entries(a).map((([r,t])=>[r,toColorValue(t)])));n.forEach((t=>{r({[`scrollbar-${t}`]:r=>({[`--scrollbar-${t}`]:toColorValue(r)})},{values:l,type:"color"})}))};
/**
 * Adds scrollbar-COMPONENT-rounded-VALUE utilities for every scrollbar
 * component.
 *
 * @param {typedefs.TailwindPlugin} tailwind - Tailwind's plugin object
 */const addRoundedUtilities$1=({theme:r,matchUtilities:t})=>{n.forEach((a=>{t({[`scrollbar-${a}-rounded`]:r=>({[`--scrollbar-${a}-radius`]:r})},{values:r("borderRadius")})}))};
/**
 * @param {typedefs.TailwindPlugin} tailwind - Tailwind's plugin object
 * @param {'standard' | 'peseudoelements'} preferredStrategy - The preferred
 *    scrollbar styling strategy: standards track or pseudoelements
 */const addBaseSizeUtilities$1=({addUtilities:r},t)=>{r(generateScrollbarSizeUtilities({preferPseudoElements:t==="pseudoelements"}))};
/**
 * Adds scrollbar-w-* and scrollbar-h-* utilities
 *
 * @param {typedefs.TailwindPlugin} tailwind - Tailwind's plugin object
 */const addSizeUtilities$1=({matchUtilities:r,theme:t})=>{["width","height"].forEach((a=>{r({[`scrollbar-${a[0]}`]:r=>({[`--scrollbar-${a}`]:r})},{values:t(a)})}))};s={addBaseStyles:addBaseStyles$1,addBaseSizeUtilities:addBaseSizeUtilities$1,addColorUtilities:addColorUtilities$1,addRoundedUtilities:addRoundedUtilities$1,addSizeUtilities:addSizeUtilities$1};var b=s;var h={};
/** @typedef {import('./typedefs').TailwindPlugin} TailwindPlugin */
/**
 * Adds scrollbar variants for styling webkit scrollbars' hover and active
 * states.
 *
 * Earlier iterations of this plugin hijacked the hover: and active: variants
 * directly to create a cleaner syntax, but there are several issues with that
 * approach:
 *     - It made the plugin prone to breaking other unrelated styles
 *     - It made logic like "make an element's scrollbar green when the
 *       _element_ is hovered impossible. (This is unusual, but should still
 *       be possible.)
 *     - It straight up does not work in Tailwind v4.
 *
 * @param {TailwindPlugin} tailwind - Tailwind's plugin object
 */const addVariants$1=({addVariant:r})=>{r("scrollbar-hover","&::-webkit-scrollbar-thumb:hover");r("scrollbar-track-hover","&::-webkit-scrollbar-track:hover");r("scrollbar-corner-hover","&::-webkit-scrollbar-corner:hover");r("scrollbar-active","&::-webkit-scrollbar-thumb:active");r("scrollbar-track-active","&::-webkit-scrollbar-track:active")};h={addVariants:addVariants$1};var u=h;var p=r;try{"default"in r&&(p=r.default)}catch(r){}var v={};const m=p;const{addBaseStyles:f,addBaseSizeUtilities:w,addColorUtilities:k,addRoundedUtilities:y,addSizeUtilities:U}=b;const{addVariants:g}=u;v=m.withOptions(((r={})=>t=>{let a=r.preferredStrategy??r.preferredstrategy??"standard";if(a!=="standard"&&a!=="pseudoelements"){console.warn("WARNING: tailwind-scrollbar preferredStrategy should be 'standard' or 'pseudoelements'");a="standard"}f(t,a);w(t,a);k(t);g(t);if(r.nocompatible){y(t);U(t)}}));var $=v;export{$ as default};

