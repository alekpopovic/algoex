defmodule Algoex.Stochastic.AdaptiveRandomSearch do
  @spec perform(non_neg_integer(), integer(), number(), any(), any(), any(), any()) :: any()
  def perform(problem_size, max_iter, init_factor, s_factor, l_factor, iter_mult, max_no_impr) do
    bounds = List.duplicate([-5, 5], problem_size)
    bounds1 = bounds |> List.first() |> elem(1)
    bounds2 = bounds |> List.first() |> elem(0)
    step_size = (bounds1 - bounds2) * init_factor
    current = %{
      vector: random_vector(bounds),
      cost: objective_function(random_vector(bounds))
    }
    count = 0

    {best, _} = Enum.reduce_while(1..max_iter, {current, step_size, count}, fn iter, {current, step_size, count} ->
      big_stepsize = large_step_size(iter, step_size, s_factor, l_factor, iter_mult)
      {step, big_step} = take_steps(bounds, current, step_size, big_stepsize)

      cond do
        step.cost <= current.cost or big_step.cost <= current.cost ->
          {new_step_size, new_current} =
            if big_step.cost <= step.cost do
              {big_stepsize, big_step}
            else
              {step_size, step}
            end

          IO.puts(" > iteration #{iter}, best=#{new_current.cost}")
          {:cont, {new_current, new_step_size, 0}}

        true ->
          new_count = count + 1
          new_step_size = if new_count >= max_no_impr, do: step_size / s_factor, else: step_size

          IO.puts(" > iteration #{iter}, best=#{current.cost}")
          {:cont, {current, new_step_size, new_count}}
      end
    end)
    |> elem(0)

    IO.puts("Done. Best Solution: c=#{best.cost}, v=#{inspect(best.vector)}")
  end

  defp objective_function(vector) do
    Enum.reduce(vector, 0, fn x, sum -> sum + x ** 2.0 end)
  end

  defp rand_in_bounds(min, max) do
    min + ((max - min) * :rand.uniform())
  end

  defp random_vector(minmax) do
    Enum.map(minmax, fn {min, max} ->
      rand_in_bounds(min, max)
    end)
  end

  defp take_step(minmax, current, step_size) do
    Enum.map(Enum.zip(minmax, current), fn {bounds, current_val} ->
      min_bound = Enum.at(bounds, 0)
      max_bound = Enum.at(bounds, 1)

      min = max(min_bound, current_val - step_size)
      max = min(max_bound, current_val + step_size)

      rand_in_bounds(min, max)
    end)
  end

  defp large_step_size(iter, step_size, s_factor, l_factor, iter_mult) do
    if iter > 0 and rem(iter, iter_mult) == 0 do
      step_size * l_factor
    else
      step_size * s_factor
    end
  end

  defp take_steps(bounds, current, step_size, big_step_size) do
    step_vector = take_step(bounds, current.vector, step_size)
    step_cost = objective_function(step_vector)
    step = %{
      vector: step_vector,
      cost: step_cost
    }

    big_step_vector = take_step(bounds, current.vector, big_step_size)
    big_step_cost = objective_function(big_step_vector)
    big_step = %{
      vector: big_step_vector,
      cost: big_step_cost
    }

    {step, big_step}
  end
end
