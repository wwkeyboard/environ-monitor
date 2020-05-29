use actix_web::{get, web, App, HttpServer, Responder};
use bme280::BME280;
use linux_embedded_hal::{Delay, I2cdev};
use std::sync::Mutex;

struct Sensor {

}

#[get("/metrics")]
async fn index() -> impl Responder {
    let i2c_bus = I2cdev::new("/dev/i2c-1").unwrap();

    let mut bme280 = BME280::new_secondary(i2c_bus, Delay);

    bme280.init().unwrap();

    let m = bme280.measure().unwrap();
    format!("env_humidity {}\nenv_temperature {}\nenv_pressure {}\n", m.humidity, m.temperature, m.pressure)
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(index))
        .bind("0.0.0.1:8080")?
        .run()
        .await
}
