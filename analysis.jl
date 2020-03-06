using JuliaDB,GLM,StatsPlots,Dates,Genie,Genie.Router

t = loadtable("covid_19_data.csv")

function exp_regress(cases)
    aggregate_cases = groupreduce((Confirmed=+,), cases, :ObservationDate, select=:Confirmed)
    case_data = select(aggregate_cases,
                       (:ObservationDate => d -> (d - Date(2020,1,1)).value, :Confirmed => n -> log(2,n)))
    regression = lm(@formula(Confirmed ~ 1 + ObservationDate), case_data)
    (regression,
     plot(select(aggregate_cases,:ObservationDate), [exp2.(select(case_data,:Confirmed)),exp2.(predict(regression,case_data))], legend=:bottomright, label=["data" "regression"],yaxis=:log))
end

function filter_date(s,e,cases)
    filter(:ObservationDate => d -> s <= d <= e,cases)
end

function filter_country(c,cases)
    filter(Symbol("Country/Region") => r -> r == c,cases)
end

function filter_state(postal,fullname,cases)
    filter(Symbol("Province/State") => ps -> length(ps) >= 2 && (ps[end-1:end] == postal || ps == fullname), cases)
end

function last_n_days(n,cases)
    filter_date(today() - Day(n), today(),cases)
end

(us15regress, us15plot) = exp_regress(t,today - Day(15),today,"US")
(it15regress, it15plot) = exp_regress(t,today - Day(15),today,"Italy")
(it10regress, it10plot) = exp_regress(t,today - Day(10),today,"Italy")
(ca5regress, ca5plot) = exp_regress(last_n_days(5,filter_state("CA","California",t)))
(uk10regress, uk10plot) = exp_regress(last_n_days(10,filter_country("UK",t)))
(de10regress, de10plot) = exp_regress(last_n_days(10,filter_country("Germany",t)))
(sp10regress, sp10plot) = exp_regress(last_n_days(10,filter_country("Spain",t)))

for c in sort(unique(select(filter(Symbol("Country/Region") => r -> r == "US",t),Symbol("Province/State"))))
    println(c)
end

route("/corona") do
    country = @params(:country)
    days = parse(Int,@params(:days))
    chartfilename = "static/$country-$days-chart.png"
    (regress,chart) = exp_regress(last_n_days(days,filter_country(country,t)))
    savefig(chart,"public/$chartfilename")
    "<p>
        In $country, for the last $days days the number of Corona cases has been doubling every $(round(1 / coef(regress)[2],digits=1)) days
    </p>
    <p>
    <img src=\"$chartfilename\"></img>
    </p>"
end

route("/static/.*") do
    serve_static_file(@params(:REQUEST).target)
end
