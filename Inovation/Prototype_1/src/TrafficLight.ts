import { Board, Led } from "johnny-five";
import { EventEmitter } from "events";

export enum TrafficLightColor {
    RED,
    GREEN,
    YELLOW,
}

export class TrafficLight extends EventEmitter {
    private _board!: Board;
    private _red_led!: Led;
    private _green_led!: Led;
    private _yellow_led!: Led;
    private _light_color!: TrafficLightColor;

    public red_led_pin: number;
    public green_led_pin: number;
    public yellow_led_pin: number;
    public init_light_color: TrafficLightColor;

    public get light_color(): TrafficLightColor {
        return this._light_color;
    }

    public set light_color(value) {
        this._light_color = value;
    }

    constructor (options = {
        red_led_pin: 13,
        green_led_pin: 12,
        yellow_led_pin: 11,
        init_light_color: TrafficLightColor.RED,
    }) {
        super();
        this.red_led_pin = options.red_led_pin;
        this.green_led_pin = options.green_led_pin;
        this.yellow_led_pin = options.yellow_led_pin;
        this.init_light_color = options.init_light_color;
    }

    public start(): void {
        this._board = new Board();
        this._board.on('ready', () => {
            this._red_led = new Led(this.red_led_pin);
            this._green_led = new Led(this.green_led_pin);
            this._yellow_led = new Led(this.yellow_led_pin);
            this.setLightColor(this.init_light_color);
            this.emit('ready');
        });
    }
    
    public setLightColor(color: TrafficLightColor): void {
        this._light_color = color;
        switch (color) {
            case TrafficLightColor.RED:
                this._red_led.on();
                this._green_led.off();
                this._yellow_led.off();
                break;
            case TrafficLightColor.GREEN:
                this._red_led.off();
                this._green_led.on();
                this._yellow_led.off();
                break;
            case TrafficLightColor.YELLOW:
                this._red_led.off();
                this._green_led.off();
                this._yellow_led.on();
        }
    }

    public nextLightColor(): void {
        switch (this._light_color) {
            case TrafficLightColor.RED:
                this.setLightColor(TrafficLightColor.GREEN);
                break;
            case TrafficLightColor.GREEN:
                this.setLightColor(TrafficLightColor.YELLOW);
                break;
            case TrafficLightColor.YELLOW:
                this.setLightColor(TrafficLightColor.RED);
        }
    }
}