# frozen_string_literal: true
require_relative './piece'

# セル
class Cell
  attr_accessor :piece

  def initialize(piece=nil)
    @piece = piece
  end

  def to_s
    blank? ? '・' : @piece.to_s
  end

  def blank?
    @piece ? false : true
  end

  def ==(other)
    if other.is_a?(Cell)
      blank? && other.blank? ||
          @piece == other&.piece
    else
      @piece == other
    end
  end

  def reverse!
    @piece.reverse!
  end
end