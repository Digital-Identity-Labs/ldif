defmodule LdifTest do
  use ExUnit.Case
  doctest Ldif

  test "greets the world" do
    assert Ldif.hello() == :world
  end
end
