//= require jquery
//= require jaws
//= require ./events
//= require_tree ./game/

window.onload = function() {
  jaws.unpack();
  jaws.assets.root = "assets/";
  jaws.assets.add([
      "char.png",
      "block.bmp",
      "grass.png",
      "overlay.png",
      "dialogborder.png",
      "fonts/museoslab500.font.png",
      "fonts/museoslab700.font.png",
      "fonts/museoslab900.font.png"
  ]);
  jaws.start(Example);
};
