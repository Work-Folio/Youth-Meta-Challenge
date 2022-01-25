from spike import PrimeHub, ColorSensor, DistanceSensor, Motor, MotorPair
from spike.control import wait_for_seconds
from math import pi

class Robot:
    TURN_DEGREE_CONST = 11.3 * pi / 360
    MOVE_MOTORS_OPTION = 'coast'
    DEFAULT_MOVE_SPEED = 50
    DEFAULT_TURN_SPEED = 50
    DEFAULT_LINE_COLOR = 'black'
    CATCH_UP_DEGREE = 0
    CATCH_DOWN_DEGREE = 260
    DEFAULT_BEEP_SECONDS = 1

    MOVE_LEFT_MOTOR_PORT = 'A'
    MOVE_RIGHT_MOTOR_PORT = 'B'
    CATCH_MOTOR_PORT = 'C'
    COLOR_SENSOR_PORT = 'D'
    DISTANCE_SENSOR_PORT = 'E'

    hub: PrimeHub
    move_motors: MotorPair
    catch_motor: Motor
    color_sensor: ColorSensor
    distance_sensor: DistanceSensor

    def __init__(self):
        self.hub = PrimeHub()
        self.move_motors = MotorPair(self.MOVE_LEFT_MOTOR_PORT, self.MOVE_RIGHT_MOTOR_PORT)
        self.catch_motor = Motor(self.CATCH_MOTOR_PORT)
        self.color_sensor = ColorSensor(self.COLOR_SENSOR_PORT)
        self.distance_sensor = DistanceSensor(self.DISTANCE_SENSOR_PORT)
        self.setup()
    
    def setup(self):
        self.catch_up()
        self.move_motors.set_stop_action(self.MOVE_MOTORS_OPTION)

    def move(self, amount: float = 0, speed: float = DEFAULT_MOVE_SPEED, steering: float = 0):
        if amount == 0:
            self.move_motors.start(steering=steering, speed=speed)
        else:
            self.move_motors.move(amount, steering=steering, speed=speed)

    def move_stop(self):
        self.move_motors.stop()

    def turn_right(self, degree: float = 90, speed: float = DEFAULT_TURN_SPEED):
        self.move_motors.move(self.TURN_DEGREE_CONST * degree, steering=100, speed=speed)

    def turn_left(self, degree: float = 90, speed: float = DEFAULT_TURN_SPEED):
        self.move_motors.move(self.TURN_DEGREE_CONST * degree, steering=-100, speed=speed)
    
    def catch_up(self):
        self.catch_motor.run_to_position(self.CATCH_UP_DEGREE)

    def catch_down(self):
        self.catch_motor.run_to_position(self.CATCH_DOWN_DEGREE, direction='counterclockwise')

    def beep(self, seconds: float = DEFAULT_BEEP_SECONDS):
        self.hub.speaker.beep(seconds=seconds)

    def wait_line(self, color: str = DEFAULT_LINE_COLOR):
        self.color_sensor.wait_until_color(color)
    
    def wait_distance(self, distance: float):
        self.distance_sensor.wait_for_distance_closer_than(distance)

class Mission(Robot):
    def __init__(self):
        super().__init__()

    def mission1(self):
        self.move()
        self.wait_line()
        self.move_stop()
        self.move(7.25)
        self.turn_left()

    def mission2(self):
        self.move()
        self.wait_line()
        self.move_stop()
        self.move(4)
        self.catch_down()
        self.move(8, speed=25)
        self.turn_left(90)
        self.move(speed=25)
        self.wait_line()
        self.move_stop()
        self.catch_up()
        self.move(35, speed=-50)
        self.turn_right()
        self.move()
        self.wait_line()
        self.move_stop()

    def mission3(self):
        self.move()
        self.wait_distance(12)
        self.move_stop()
        self.catch_down()
        self.move(12.5, speed=25)
        wait_for_seconds(3)
        self.catch_up()
        self.move()
        self.wait_line(color='red')
        self.move_stop()
    
    def mission4(self):
        self.move(5)
        while True:
            color = self.color_sensor.get_color()
            if color == 'black':
                self.move(steering=70)
            elif color == 'red':
                break
            else:
                self.move(steering=-70)
        self.move_stop()

    def mission5(self):
        self.turn_right(2)
        wait_for_seconds(3)
        self.move()
        self.wait_distance(6)
        self.move_stop()
        wait_for_seconds(1)

    def mission6(self):
        self.move(amount=75, speed=-50)
        self.turn_left()
        self.move(amount=20)
        self.beep()
        self.move(amount=15, speed=-50)
        self.turn_left()

    def mission7(self):
        self.catch_down()
        self.move(110, speed=100)
        self.catch_up()

    def all_mission(self):
        self.mission1()
        self.mission2()
        self.mission3()
        self.mission4()
        self.mission5()
        self.mission6()
        self.mission7()

Mission().all_mission()