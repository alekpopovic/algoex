defmodule Algoex.Stochastic.RandomSearch do

  # Input: NumIterations, ProblemSize
  #
  # Output: Best
  #
  # Best ←∅;
  #
  # foreach iteri ∈NumIterations do
  #   candidatei ←RandomSolution(ProblemSize, SearchSpace);
  #   if Cost(candidatei) < Cost(Best) then
  #     Best ←candidatei;
  #   end
  # end
  #
  #return Best;
  def perform(max_iter, problem_size) do
    search_space = Enum.map(1..problem_size, fn _ -> {-5, 5} end)

    {best, _} = Enum.reduce(1..max_iter, {nil, 0}, fn iter, {best, _} ->
      vector = random_vector(search_space)
      cost = objective_function(vector)
      new_best =
        cond do
          best == nil -> %{vector: vector, cost: cost}
          cost < best.cost -> %{vector: vector, cost: cost}
          true -> best
        end

      IO.puts(" > iteration=#{iter}, best=#{new_best.cost}")
      {new_best, iter}
    end)

    IO.puts("Done. Best Solution: c=#{best.cost}, v=#{inspect(best.vector)}")
  end

  defp objective_function(vector) do
    Enum.reduce(vector, 0, fn x, sum -> sum + :math.pow(x, 2.0) end)
  end

  defp random_vector(minmax) do
    Enum.map(minmax, fn {min, max} ->
      min + ((max - min) * :rand.uniform())
    end)
  end
end
