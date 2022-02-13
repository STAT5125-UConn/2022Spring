using DataFrames, Latexify
df = DataFrame(x=x, y=y, x²=x.^2, y²=y.^2, α=x.*y) 
df_show = round.(first(df, 10), digits=3)
tb = latexify(df_show, latex=false, booktabs=true, env=:table)
print(tb)
# latexify(tb, latex=false, booktabs=true, env=:table)
# Pkg.add("TexTables")
# using TexTables
# to_tex(tb)
# latexify(first(df, 5))
