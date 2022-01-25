import { TrafficLight } from "./TrafficLight";

function sleep(tm: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, tm));
}

const trafficLight = new TrafficLight();

trafficLight.on('ready', async () => {
    await sleep(60 * 60 * 1000);
    trafficLight.nextLightColor();
    await sleep(60 * 60 * 1000);
    trafficLight.nextLightColor();
});

trafficLight.start();