# frozen_string_literal: true
# 石
# 色をもつ
class Piece
  COLOR_DARK = :dark.freeze
  COLOR_LIGHT = :light.freeze
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    case @color
      when COLOR_DARK
        '●'
      when COLOR_LIGHT
        '○'
      else
        raise ArgumentError
    end
  end

  # 同じ色か同じ色の石
  def ==(other)
    other.is_a?(Piece) ?
        @color == other&.color :
        @color == other
  end

  def reverse!
    case @color
      when COLOR_DARK
        light!
      when COLOR_LIGHT
        dark!
      else
        raise ArgumentError
    end
  end

  def light!
    @color = COLOR_LIGHT
  end

  def dark!
    @color = COLOR_DARK
  end
end