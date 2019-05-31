##
# WiringPi - for raspberry pi GPIO/Serial Control
#

module WiringPi
  WPI_MODE_PINS = 0 # Use sane pin numbering
  WPI_MODE_GPIO = 1 # Use Broadcom barmy GPIO pin numbering
  WPI_MODE_SYS  = 2 # Use /sys/class/gpio method

  # Constants for mode()
  INPUT = 'in'
  OUTPUT = 'out'
  PWM_OUTPUT = 'pwm'

  # Constants for digitalWrite()
  HIGH = 1
  LOW = 0

  PUD_OFF = 'tri'
  PUD_DOWN = 'down'
  PUD_UP = 'up'

  # Bit-order for shiftOut and shiftIn
  LSBFIRST = 0 # Least Significant Bit First
  MSBFIRST = 1 # Most Significant Bit First

  class Serial
    @id = 0
    @device = '/dev/ttyAMA0'
    @baud = 9600

    def initialize(device='/dev/ttyAMA0', baud=9600)
      @device = device
      @baud = baud

      @id = Wiringpi.serialOpen(@device, @baud)
    end

    def serialClose
      Wiringpi.serialClose(@id)
      @id = 0
    end

    def serialPutchar(char)
      Wiringpi.serialPutchar(@id, char)
    end

    def serialPuts(string)
      Wiringpi.serialPuts(@id, string)
    end

    def serialDataAvail
      Wiringpi.serialDataAvail(@id)
    end

    def serialGetchar
      Wiringpi.serialGetchar(@id)
    end
  end

  class GPIO
    GPIO_PINS = [
      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,21,22,23,24,25,26,27,28,29,30,31  # seemingly random indeed!
    ]

    PINS = [
      0,1,2,3,4,5,6,7, # basic IO pins
      8,9,             # i2c with 1k8 pull up resistor
      10,11,12,13,14,     # SPI pins, can also be used for IO
      15,16,17
    ]

    @mode = WPI_MODE_PINS

    @@init = false  # once wiringPiSetup has been called, we don't have to do it again

    def initialize( mode=WPI_MODE_PINS )
      @mode = mode
      self.wiringPiSetup unless @@init
    end

    def wiringPiMode( mode )
      @mode = mode
      Wiringpi.wiringPiGpioMode( @mode )
    end

    def wiringPiSetup
      begin
        if @mode == WPI_MODE_PINS
          Wiringpi.wiringPiSetup
        elsif @mode == WPI_MODE_GPIO
          Wiringpi.wiringPiSetupGpio
        elsif @mode == WPI_MODE_SYS
          Wiringpi.wiringPiSetupSys
        end
      rescue Exception=>e
        raise e
      end

      #Wiringpi.wiringPiGpioMode( @mode )
      @@init = true
    end

    def checkPin(pin)
      ( @mode = WPI_MODE_PINS and PINS.include?(pin) ) or ( @mode = WPI_MODE_GPIO and GPIO_PINS.include?(pin) )
    end

    def pinError(pin)
      "invalid #{pin}, available gpio pins: #{PINS}" if @mode == WPI_MODE_PINS
      "invalid #{pin}, available gpio pins: #{GPIO_PINS}" if @mode == WPI_MODE_GPIO
    end

    def read(pin)
      raise ArgumentError, pinError(pin) unless checkPin(pin)

      Wiringpi.digitalRead(pin)
    end

    def pwmWrite(pin,value)
      raise ArgumentError, pinError(pin) unless checkPin(pin)

      Wiringpi.pwmWrite(pin,value)
    end

    def write(pin,value)
      raise ArgumentError, pinError(pin) unless checkPin(pin)
      raise ArgumentError, 'invalid value' unless [0,1].include?(value)

      Wiringpi.digitalWrite(pin,value)
    end

    def mode(pin,mode)
      raise ArgumentError, pinError(pin) unless checkPin(pin)
      raise ArgumentError, "invalid mode" unless [INPUT,OUTPUT,PWM_OUTPUT].include?(mode)

      Wiringpi.pinMode(pin, mode)
    end

    def shiftOutArray(dataPin, clockPin, latchPin, bits)
      raise ArgumentError, "invalid data pin, available gpio pins: #{PINS}" unless checkPin(dataPin)
      raise ArgumentError, "invalid clock pin, available gpio pins: #{PINS}" unless checkPin(clockPin)
      raise ArgumentError, "invalid latch pin, available gpio pins: #{PINS}" unless checkPin(latchPin)

      Wiringpi.digitalWrite( latchPin, LOW )

      bits.each_slice(8) do |slice|
        Wiringpi.shiftOut(dataPin, clockPin, LSBFIRST, slice.reverse.join.to_i(2)) 
      end

      Wiringpi.digitalWrite( latchPin, HIGH )
    end

    def shiftOut(dataPin, clockPin, byteOrder, char)
      Wiringpi.shiftOut(dataPin, clockPin, byteOrder, char)
    end

    def readAll
      pinValues = Hash.new
      if @mode == WPI_MODE_GPIO
        GPIO_PINS.each do |pin|
          pinValues[pin] = self.read(pin)
        end
      else
        PINS.each do |pin|
          pinValues[pin] = self.read(pin)
        end
      end
      pinValues
    end
  end
end
