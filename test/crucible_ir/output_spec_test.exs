defmodule CrucibleIR.OutputSpecTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.OutputSpec

  describe "struct creation" do
    test "creates with required name field" do
      spec = %OutputSpec{name: :results}
      assert spec.name == :results
    end

    test "sets default formats to [:markdown]" do
      spec = %OutputSpec{name: :results}
      assert spec.formats == [:markdown]
    end

    test "sets default sink to :file" do
      spec = %OutputSpec{name: :results}
      assert spec.sink == :file
    end

    test "allows custom formats" do
      spec = %OutputSpec{name: :results, formats: [:json, :html]}
      assert spec.formats == [:json, :html]
    end

    test "allows custom sink" do
      spec = %OutputSpec{name: :results, sink: :stdout}
      assert spec.sink == :stdout
    end

    test "accepts options" do
      spec = %OutputSpec{name: :results, options: %{path: "/tmp/results"}}
      assert spec.options == %{path: "/tmp/results"}
    end

    test "options default to nil" do
      spec = %OutputSpec{name: :results}
      assert spec.options == nil
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      spec = %OutputSpec{name: :results, formats: [:markdown, :json]}
      {:ok, json} = Jason.encode(spec)
      assert json =~ "results"
      assert json =~ "markdown"
      assert json =~ "json"
    end

    test "encodes with all fields" do
      spec = %OutputSpec{
        name: :results,
        formats: [:latex, :html],
        sink: :s3,
        options: %{bucket: "my-bucket"}
      }

      {:ok, json} = Jason.encode(spec)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["sink"] == "s3"
      assert decoded["options"]["bucket"] == "my-bucket"
    end
  end
end
