mruby-WiringPi
=========

## How to use

- Install [WiringPI](http://wiringpi.com) library (for Raspberry Pi):

        git clone git://git.drogon.net/wiringPi
        cd wiringPi
        ./build

- Install [gpio_lib_c](https://github.com/TinkerBoard/gpio_lib_c) (for Tinker Board):

        git clone https://github.com/TinkerBoard/gpio_lib_c.git
        cd gpio_lib_c
        ./build

- checkout mruby

```bash
git clone https://github.com/mruby/mruby.git  # original mruby
  # or
git clone https://github.com/iij/mruby.git    # iij extended mruby (File, IO, Socket, ... extend)
```

- edit `build_config.rb`

```ruby
MRuby::Build.new do |conf|

  # ... (snip) ...
  conf.gem :github => 'm-asahi/mruby-WiringPi'   # add this line
  conf.gem :github => 'matsumoto-r/mruby-sleep'  # add this line
end
```

- build `ruby ./minirake`
- exec `sudo ./bin/mruby build/mrbgems/mruby-WiringPi/sample/sample.rb`

## Pin Mapping

| wiringPi | GPIO (RasPi Pin#) | GPIO (Tinker Board Pin#) | Name   |
|:--------:|:----:|:----:|:------:|
|      0   |  17  | 164 | GPIO 0 |
|      1   |  18  | 184 | GPIO 1 |
|      2   |  27  | 166 | GPIO 2 |
|      3   |  22  | 167 | GPIO 3 |
|      4   |  23  | 162 | GPIO 4 |
|      5   |  24  | 163 | GPIO 5 |
|      6   |  25  | 171 | GPIO 6 |
|      7   |   4  | 17  | GPIO 7 |
|      8   |   2  | 252 | SDA    |
|      9   |   3  | 253 | SCL    |
|     10   |   8  | 255 | CE0    |
|     11   |   7  | 251 | CE1    |
|     12   |  10  | 257 | MOSI   |
|     13   |   9  | 256 | MISO   |
|     14   |  11  | 254 | SCLK   |
|     15   |  14  | 161 | TxD    |
|     16   |  15  | 160 | RxD    |
|     21   |   5  | 165 | GPIO21 |
|     22   |   6  | 168 | GPIO22 |
|     23   |  13  | 238 | GPIO23 |
|     24   |  19  | 185 | GPIO24 |
|     25   |  26  | 224 | GPIO25 |
|     26   |  12  | 239 | GPIO26 |
|     27   |  16  | 223 | GPIO27 |
|     28   |  20  | 187 | GPIO28 |
|     29   |  21  | 188 | GPIO29 |
|     30   |   0  | 233 | GPIO30 |
|     31   |   1  | 234 | GPIO31 |

## sample

```ruby
io = WiringPi::GPIO.new
pin = 0
io.mode(pin, WiringPi::OUTPUT)

5.times do
  puts "pin:#{pin} set high"
  io.write(pin, WiringPi::HIGH)
  sleep 1
  puts "pin:#{pin} set low"
  io.write(pin, WiringPi::LOW)
  sleep 1
end
io.read(pin)
```

 - WiringPi::Serial is not tested...

## sample (LCD)

 - LCD control sample code for SC1602 http://akizukidenshi.com/catalog/g/gP-00038/

| wiringPi | GPIO (Pin#) | Name   | LCD Port |
|:--------:|:----:|:------:|:------:|
|      0   |  17  | GPIO 0 |  DB0 |
|      1   |  18  | GPIO 1 |  DB1 |
|      2   |  27  | GPIO 2 |  DB2 |
|      3   |  22  | GPIO 3 |  DB3 |
|      4   |  23  | GPIO 4 |  DB4 |
|      5   |  24  | GPIO 5 |  DB5 |
|      6   |  25  | GPIO 6 |  DB6 |
|      7   |   4  | GPIO 7 |  DB7 |
|     12   |  10  | MOSI   | Enable |
|     13   |   9  | MISO   | Register Select |

 - The Read/Write pin must be connected to 0V/Ground.

```ruby
lcd = LCD.new rows: 18, cols: 2, bits: 8, rs: 13, strb: 12, dpin: [0,1,2,3,4,5,6,7]

lcd.lcd_pos 0, 0
lcd.lcd_puts "Hello, mruby"
lcd.lcd_pos 0, 1
lcd.lcd_puts "Hi, Raspberry Pi"
```


## TODO

 - cross build support

## License
This software is licensed under the same license terms of [WiringPI](http://wiringpi.com).

