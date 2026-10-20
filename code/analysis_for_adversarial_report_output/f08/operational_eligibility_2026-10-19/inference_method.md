# Confidence envelopes for partially classified binary outcomes

The estimation population and instrument/controls are held fixed. This calculation does not reweight by a post-offer outcome or assume that uncertain students resemble classified students.

Let W contain the controls, application-year indicators and chance-group effects, M = I − P_W, z = M·OFFER, and d = M·D_OD. For IV define w = z/(z'd); for RF define w = z/(z'z) and replace d by z below. The first stage is positive and strong in these samples. For any outcome vector y, b(y) = w'y. If L ≤ y ≤ U, define m = (L+U)/2 and a = (U−L)/2. The exact outer coefficient range over independent individual completions is

    b_min = w'm − Σ |w_i| a_i
    b_max = w'm + Σ |w_i| a_i.

These individual completions can be more permissive than jointly feasible school ranks, so this is an outer range. Regressing L and U separately does not yield these bounds because w has both signs.

The IV residual is u(y) = M y − d b(y). Demean the non-FE controls within chance groups to obtain X, and set A = (X'X)^{-1}. The projection is the sum of the group-mean projection and XAX'. A componentwise bound valid for every y in the box is

    |u_i(y) − u_i(m)| ≤ e_i
    e_i = a_i + group_mean_i(a)
          + [ |XA| (|X|'a) ]_i
          + |d_i| Σ |w_j| a_j.

The HC0 variance for b is Σ (w_i u_i)^2. Therefore

    SE(y) ≤ S = sqrt[Σ w_i² (|u_i(m)| + e_i)²].

The reported envelope is [b_min − 1.96 S, b_max + 1.96 S]. It contains the conventional HC0 normal Wald interval for every admissible completion, including the unknown actual one. Consequently it inherits the usual asymptotic coverage of that underlying IV interval under the maintained IV and independent-observation robust-sampling assumptions. It is not an exact finite-sample guarantee, a sharp identified set, or protection against errors outside the allowed input/classification uncertainty. For RF the implementation uses the established HC1 finite-sample factor and t critical value. No clustering or new variance convention is silently substituted for the finalized score specification.

When L=U, a=0 and the method reduces exactly to the conventional robust interval. Code checks coefficients and HC0 SE against fixest for midpoint and both coefficient-extremizing completions; the midpoint is a computational device, not a reported eligibility estimate. A small-design check exhaustively enumerates 64 binary completions. The fixed-design derivation avoids assigning ordinary bootstrap SE to a sign-selected endpoint outcome.

## Additional errors among determinate outcomes

The stress test allows up to k currently determinate outcomes to be wrong, in addition to all baseline unresolved completions. For the upper coefficient endpoint, sort the positive gains from flipping a determinate 0 when w>0 or a determinate 1 when w<0, and add the largest k. Reverse the signs for the lower endpoint. This is exact for the fitted coefficient over that enlarged label set.

For a vector δ changing at most k determinate binary outcomes, ||δ||₂ ≤ √k. Since M is an orthogonal projection,

    ||diag(w) M δ||₂ ≤ max_i |w_i| √k.

Also |w'δ| is bounded by the sum G_k of the k largest |w_i| among determinate observations. Thus the robust SE is bounded by

    S_extra = S + max_i |w_i| √k + ||w ⊙ d||₂ G_k,

with the same HC1 adjustment for RF where applicable. Combining this SE bound with the expanded coefficient range gives the additional-error confidence envelope. The chosen 0.1%, 0.5% and 1% budgets refer to the entire lottery population. They are assumptions for sensitivity analysis, not estimated population error rates; selected-applicant administrative agreement is not extrapolated to nonapplicants.

## Scope of input uncertainty

The baseline box covers missing/conflicting histories, missing scores and peer membership, ambiguous graduation schools, both plausible 2021 rosters, and percentile ties/quota rounding. Score-error variants enlarge the input-score intervals and recompute peer ranks. Administrative disagreement diagnostics reveal that some determinate classifications can still be incorrect; the additional-error analysis addresses this separately. These effects do not decompose causal mediation by school access versus academic standing.
