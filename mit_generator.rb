require 'ruby2d'
require 'clipboard'

# Configuration
VP_WIDTH, VP_HEIGHT = 800, 600

# Global state variables
$year = ""
$author = ""
$license_text = "Please enter the year and author above to generate the MIT License text."
$message = ""
$message_type = ""
$message_timer = 0

# UI elements
$year_input = nil
$author_input = nil
$generate_button = nil
$copy_button = nil
$license_output = nil
$message_display = nil

# Input state
$active_input = nil
$cursor_position = 0
$cursor_visible = true
$cursor_timer = 0

# Setup
set(
  title: 'MIT License Generator',
  width: VP_WIDTH,
  height: VP_HEIGHT,
  background: 'white'
)

# Create UI elements

def create_ui
  # Input section background
  Rectangle.new(
    x: 20,
    y: 20,
    width: VP_WIDTH - 40,
    height: 120,
    color: '#f5f5f5'
  )
  
  # Copyright label
  Text.new(
    'Copyright (c)',
    x: 30,
    y: 60,
    font: Font.default,
    size: 18,
    color: 'black'
  )
  
  # Year input field
  $year_field = Rectangle.new(
    x: 180,
    y: 50,
    width: 100,
    height: 30,
    color: 'white'
  )
  
  # Year input text
  $year_input = Text.new(
    $year,
    x: 185,
    y: 53,
    size: 16,
    color: 'black'
  )
  
  # Author input field
  $author_field = Rectangle.new(
    x: 300,
    y: 50,
    width: VP_WIDTH - 340,
    height: 30,
    color: 'white'
  )
  
  # Author input text
  $author_input = Text.new(
    $author,
    x: 305,
    y: 53,
    size: 16,
    color: 'black'
  )
  
  # Generate button
  $generate_button = Rectangle.new(
    x: 30,
    y: 100,
    width: 150,
    height: 35,
    color: '#6c757d',  # Disabled by default
  )
  
  Text.new(
    'Generate License',
    x: $generate_button.x + 20,
    y: $generate_button.y + 7,
    size: 16,
    color: 'white'
  )
  
  # Copy button
  $copy_button = Rectangle.new(
    x: 200,
    y: 100,
    width: 150,
    height: 35,
    color: '#6c757d',  # Disabled by defaul
  )
  
  Text.new(
    'Copy to Clipboard',
    x: $copy_button.x + 15,
    y: $copy_button.y + 7,
    size: 16,
    color: 'white'
  )
  
  # License output area
  Rectangle.new(
    x: 20,
    y: 160,
    width: VP_WIDTH - 40,
    height: VP_HEIGHT - 200,
    color: '#f8f9fa'
  )
  
  # License text - this will be updated dynamically
  update_license_output
  
  # Message area
  $message_display = Text.new(
    $message,
    x: 30,
    y: VP_HEIGHT - 30,
    size: 16,
    color: 'black'
  )
end

# Update license output text
def update_license_output
  $license_output.remove if $license_output
  
  # Draw license text directly
  $license_output = Text.new(
    $license_text,
    x: 40,
    y: 180,
    size: 14,
    color: 'black'
  )
end

# Update message display
def update_message
  $message_display.remove if $message_display
  
  $message_display = Text.new(
    $message,
    x: 30,
    y: VP_HEIGHT - 30,
    size: 16,
    color: $message_type == 'success' ? '#28a745' : '#dc3545'
  )
end

# Validate inputs
def validate_inputs
  valid_year = $year.match?(/^\d{4}$/)
  valid_author = !$author.strip.empty?
  
  if valid_year && valid_author
    $generate_button.color = '#007bff'
  else
    $generate_button.color = '#6c757d'
  end
  
  valid_year && valid_author
end

# Generate license text
def generate_license
  if validate_inputs
    $license_text = <<~LICENSE
MIT License

Copyright (c) #{$year} #{$author}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE
    
    update_license_output
    $copy_button.color = '#007bff'
    show_message("License generated successfully!", "success")
  end
end

# Copy license to clipboard
def copy_to_clipboard
  begin
    Clipboard.copy($license_text)
    show_message("License copied to clipboard!", "success")
  rescue => e
    show_message("Failed to copy license to clipboard", "error")
  end
end

# Show message
def show_message(text, type)
  $message = text
  $message_type = type
  $message_timer = 300  # 3 seconds at 60fps
  update_message
end

# Update message timer
def update_message_timer
  if $message_timer > 0
    $message_timer -= 1
  elsif $message_timer == 0
    $message = ""
    update_message
    $message_timer = -1
  end
end

# Update cursor timer
def update_cursor
  $cursor_timer += 1
  if $cursor_timer >= 30  # Blink every 0.5 seconds at 60fps
    $cursor_visible = !$cursor_visible
    $cursor_timer = 0
  end
end

# Handle mouse click
def handle_mouse_click(x, y)
  # Check year input field
  if x >= 180 && x <= 280 && y >= 50 && y <= 80
    $active_input = :year
    $cursor_position = $year.length
  # Check author input field
  elsif x >= 300 && x <= VP_WIDTH - 40 && y >= 50 && y <= 80
    $active_input = :author
    $cursor_position = $author.length
  # Check generate button
  elsif x >= $generate_button.x && x <= $generate_button.x + $generate_button.width &&
        y >= $generate_button.y && y <= $generate_button.y + $generate_button.height
    $active_input = nil
    generate_license
  # Check copy button
  elsif x >= $copy_button.x && x <= $copy_button.x + $copy_button.width &&
        y >= $copy_button.y && y <= $copy_button.y + $copy_button.height
    $active_input = nil
    copy_to_clipboard
  else
    $active_input = nil
  end
  
  # Redraw input fields with active state
  draw_input_fields
end

# Handle key press
def handle_key_press(key)
  return unless $active_input
  
  case key
  when 'backspace'
    if $active_input == :year
      $year = $year.chop if $year.length > 0
      $cursor_position = [$cursor_position - 1, 0].max
    else
      $author = $author.chop if $author.length > 0
      $cursor_position = [$cursor_position - 1, 0].max
    end
  when 'left'
    $cursor_position = [$cursor_position - 1, 0].max
  when 'right'
    max_pos = $active_input == :year ? $year.length : $author.length
    $cursor_position = [$cursor_position + 1, max_pos].min
  when 'return'
    # Generate license if both inputs are valid
    generate_license if validate_inputs
  else
    # Only allow digits for year input
    if $active_input == :year
      return unless key =~ /\d/ && $year.length < 4
      $year += key
      $cursor_position += 1
    elsif key.length == 1 && $author.length < 100
      # Allow any character for author input
      $author += key
      $cursor_position += 1
    end
  end
  
  # Redraw input fields and validate
  draw_input_fields
  validate_inputs
end

# Draw input fields
def draw_input_fields
  # Remove existing input text
  $year_input.remove if $year_input
  $author_input.remove if $author_input
  
  # Redraw year input
  $year_input = Text.new(
    $year,
    x: 185,
    y: 53,
    size: 16,
    color: 'black'
  )
  
  # Redraw author input
  $author_input = Text.new(
    $author,
    x: 305,
    y: 53,
    size: 16,
    color: 'black'
  )
  
  # Active input indication removed due to Ruby2D limitations
  $year_field.color = $active_input == :year ? '#98fb98' : 'white'
  $author_field.color = $active_input == :author ? '#98fb98' : 'white'
end

# Mouse click handler
on :mouse_down do |event|
  handle_mouse_click(event.x, event.y)
end

# Key press handler
on :key_down do |event|
  handle_key_press(event.key)
end

# Update handler (called every frame)
update do
  update_message_timer
  update_cursor
  
  # Redraw input fields to update cursor
  draw_input_fields if $active_input
end

# Create the UI and start the application
create_ui
show