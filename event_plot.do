cd "C:\Users\siyoung\Desktop\Korea Data Project\code_siyoung"

use intermediary.dta, clear

encode KEY, gen(KEY_num)
// keep Card_Spending_AMT KEY KEY_num HSHD_SEQNO BS_YR_MON birth_event
drop if missing(birth_event)


gen BS_YR_MON_m = mofd(dofc(BS_YR_MON))
format BS_YR_MON_m %tm

// Aggregate
xtevent Card_Spending_AMT, policyvar(birth_event) ///
    panelvar(KEY_num) timevar(BS_YR_MON_m) window(6) reghdfe  plot


	
	
// Heterogenous Plot

tempfile all_results
save `all_results', emptyok
levelsof sns_quantile, local(qs)
foreach q of local qs {
    preserve
        keep if sns_quantile == "`q'"

        quietly xtevent Card_Spending_AMT, ///
            policyvar(birth_event) ///
            panelvar(KEY_num) ///
            timevar(BS_YR_MON_m) ///
			regdfe //
            window(6)

        quietly xteventplot, title("sns Q: `q'") name(g`q', replace)
        graph export "sns_Q`q'.png", name(g`q') replace

        keep event_time estimate stderr quantile
        append using `all_results'
        save `all_results', replace
    restore
}