if Code.ensure_loaded?(Poison.Encoder) do
  defimpl Poison.Encoder, for: Decimal do
    def encode(decimal, _opts), do: <<?", Decimal.to_string(decimal, :normal)::binary, ?">>
  end
end

for encoder <- [Poison.Encoder, Jason.Encoder] do
  if Code.ensure_loaded?(encoder) do
    defimpl encoder, for: Ecto.Association.NotLoaded do
      def encode(%{__owner__: _owner, __field__: _field}, _) do
        "null"
      end
    end

    defimpl encoder, for: Ecto.Schema.Metadata do
      def encode(%{schema: schema}, _) do
        raise """
        cannot encode metadata from the :__meta__ field for #{inspect schema} \
        to JSON. This metadata is used internally by ecto and should never be \
        exposed externally.

        You can either map the schemas to remove the :__meta__ field before \
        encoding to JSON, or explicit list the JSON fields in your schema:

            defmodule #{inspect schema} do
              # ...

              @derive {#{unquote(inspect encoder)}, only: [:name, :title, ...]}
              schema ... do
        """
      end
    end
  end
end
