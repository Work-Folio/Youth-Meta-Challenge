#include <SoftwareSerial.h>

#define BT_RXD 2
#define BT_TXD 3
#define RED_LED_PIN 13
#define GREEN_LED_PIN 12
#define YELLOW_LED_PIN 11

typedef enum {
  RED,
  GREEN,
  YELLOW,
} Color;

SoftwareSerial BT(BT_TXD, BT_RXD);
char command;

void setup() {
  Serial.begin(9600);
  BT.begin(9600);

  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(YELLOW_LED_PIN, OUTPUT);
}

void changeColor(Color color) {
  switch (color) {
    case RED:
      digitalWrite(RED_LED_PIN, HIGH);
      digitalWrite(GREEN_LED_PIN, LOW);
      digitalWrite(YELLOW_LED_PIN, LOW);
      break;
    case GREEN:
      digitalWrite(RED_LED_PIN, LOW);
      digitalWrite(GREEN_LED_PIN, HIGH);
      digitalWrite(YELLOW_LED_PIN, LOW);
      break;
     case YELLOW:
      digitalWrite(RED_LED_PIN, LOW);
      digitalWrite(GREEN_LED_PIN, LOW);
      digitalWrite(YELLOW_LED_PIN, HIGH);
  }
}

void loop() {
  if (BT.available()) {
    command = BT.read();
    switch (command) {
      case 'r':
        changeColor(RED);
        break;
      case 'g':
        changeColor(GREEN);
        break;
      case 'y':
        changeColor(YELLOW);
    }
  }
}
