module ColorUtils
  def rgb(color)
    return color if color.is_a?(Array)

    if /#(?<r>\w{2})(?<g>\w{2})(?<b>\w{2})/ =~ color
      return [r, g, b].map(&:hex)
    elsif /rgb\((?<r>\d+),\s*(?<g>\d+),\s*(?<b>\d+)\)/ =~ color
      return [r, g, b].map(&:to_i)
    end

    return [255, 255, 255] if color == 'white'
    [0, 0, 0]
  end

  def color_str(color)
    if color.is_a?(Array)
      "rgb(#{color[0] || 0}, #{color[1] || 0}, #{color[2] || 0})"
    else
      color
    end
  end

  def invert_color(color)
    rgb(color).map { |c| 255 - c }
  end

  def contrasting_color(color)
    color = rgb(color)
    intensity(color) > 127 ? [0,0,0] : [255,255,255]
  end

  def intensity(color)
    color = rgb(color)
    # NOTE the constants here are supposed luminance weights
    (color[0] * 299 + color[1] * 587 + color[2] * 144) / 1000
  end
end
