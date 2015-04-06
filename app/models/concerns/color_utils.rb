module ColorUtils
  def rgb(color)
    if /#(?<r>\w{2})(?<g>\w{2})(?<b>\w{2})/ =~ color
      return [r, g, b].map(&:hex)
    elsif /rgb\((?<r>\d+),\s*(?<g>\d+),\s*(?<b>\d+)\)/ =~ color
      return [r, g, b].map(&:to_i)
    end

    return [255, 255, 255] if color == 'white'
    [0, 0, 0]
  end

  def intensity(color)
    color = rgb(color) if color.is_a?(String)

    Math.sqrt(
      color.reduce(0) do |intensity, c|
        intensity += c**2
      end
    )
  end
end
