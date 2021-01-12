class Boot extends hxd.App {
	public static var ME:Boot;

	override function update(dt:Float) {}

	override function init() {
		ME = this;
		new Chip8();
		onResize();
		var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		tf.text = "Hello World !";

		// Create a custom graphics object by passing a 2d scene reference.
		var customGraphics = new h2d.Graphics(s2d);

		// specify a color we want to draw with
		customGraphics.beginFill(0xEA8220);
		// Draw a rectangle at 10,10 that is 300 pixels wide and 200 pixels tall
		customGraphics.drawRect(10, 10, 300, 200);
		// End our fill
		customGraphics.endFill();
	}

	static function main() {
		new Boot();
	}
}
