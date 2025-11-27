defmodule CrucibleIR.DatasetRefTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.DatasetRef

  describe "struct creation" do
    test "creates with required name field" do
      ref = %DatasetRef{name: :mmlu}
      assert ref.name == :mmlu
    end

    test "sets default provider to :crucible_datasets" do
      ref = %DatasetRef{name: :mmlu}
      assert ref.provider == :crucible_datasets
    end

    test "sets default split to :train" do
      ref = %DatasetRef{name: :mmlu}
      assert ref.split == :train
    end

    test "allows custom provider" do
      ref = %DatasetRef{name: :custom, provider: :huggingface}
      assert ref.provider == :huggingface
    end

    test "allows custom split" do
      ref = %DatasetRef{name: :mmlu, split: :test}
      assert ref.split == :test
    end

    test "accepts options" do
      ref = %DatasetRef{name: :mmlu, options: %{limit: 100}}
      assert ref.options == %{limit: 100}
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      ref = %DatasetRef{name: :mmlu, split: :test}
      {:ok, json} = Jason.encode(ref)
      assert json =~ "mmlu"
      assert json =~ "test"
    end

    test "encodes with options" do
      ref = %DatasetRef{name: :mmlu, options: %{limit: 50}}
      {:ok, json} = Jason.encode(ref)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["options"]["limit"] == 50
    end
  end
end
