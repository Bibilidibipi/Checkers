require 'io/console'

# Reads keypresses from the user including 2 and 3 escape character sequences.
def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

# oringal case statement from:
# http://www.alecjacobson.com/weblog/?p=75
def get_single_key
  c = read_char

  case c
  when " "
    :return
  when "\e[A"
    [-1, 0]
  when "\e[B"
    [1, 0]
  when "\e[C"
    [0, 1]
  when "\e[D"
    [0, -1]
  when /^.$/
    "#{c.inspect}"
  else
    raise
  end

rescue
  retry
end
