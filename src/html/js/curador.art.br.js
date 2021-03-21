var CURADOR_XHR = (function(){
 'use strict';

 var methods = {};

 var timings = {};

 var url = "http://curador.art.br.s3-website-us-east-1.amazonaws.com";

 //
 // Methods
 //
 methods.get = async function(path) {
   var zuuid = path;

   var endpoint = url + path;
   var config = {
       headers: {
       }
     };

   return await axios
     .get(endpoint, config)
     .then(response => {
       return response;
     })
     .finally(() => {
     });
 };

 // Expose the public methods
 return methods;
})();
