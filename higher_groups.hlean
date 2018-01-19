/-
Copyright (c) 2015 Ulrik Buchholtz, Egbert Rijke and Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ulrik Buchholtz, Egbert Rijke, Floris van Doorn

Formalization of the higher groups paper
-/

import .move_to_lib
open eq is_conn pointed is_trunc trunc equiv is_equiv trunc_index susp nat algebra
     prod.ops sigma sigma.ops
namespace higher_group
set_option pp.binder_types true
universe variable u

/- We require that the carrier has a point (preserved by the equivalence) -/

structure Grp (n k : ℕ) : Type := /- (n,k)Grp, denoted here as [n;k]Grp -/
  (car : ptrunctype.{u} n)
  (B : pconntype.{u} (k.-1)) /- this is Bᵏ -/
  (e : car ≃* Ω[k] B)

structure InfGrp (k : ℕ) : Type := /- (∞,k)Grp, denoted here as [∞;k]Grp -/
  (car : pType.{u})
  (B : pconntype.{u} (k.-1)) /- this is Bᵏ -/
  (e : car ≃* Ω[k] B)

structure ωGrp (n : ℕ) := /- (n,ω)Grp, denoted here as [n;ω]Grp -/
  (B : Π(k : ℕ), (n+k)-Type*[k.-1])
  (e : Π(k : ℕ), B k ≃* Ω (B (k+1)))

attribute InfGrp.car Grp.car [coercion]

variables {n k l : ℕ}
notation `[`:95 n:0 `; ` k `]Grp`:0 := Grp n k
notation `[∞; `:95 k:0 `]Grp`:0 := InfGrp k
notation `[`:95 n:0 `;ω]Grp`:0 := ωGrp n

open Grp
open InfGrp (renaming B→iB e→ie)
open ωGrp (renaming B→oB e→oe)

/- some basic properties -/
lemma is_trunc_B' (G : [n;k]Grp) : is_trunc (k+n) (B G) :=
begin
  apply is_trunc_of_is_trunc_loopn,
  exact is_trunc_equiv_closed _ (e G),
  exact _
end

lemma is_trunc_B (G : [n;k]Grp) : is_trunc (n+k) (B G) :=
transport (λm, is_trunc m (B G)) (add.comm k n) (is_trunc_B' G)

local attribute [instance] is_trunc_B

definition Grp.sigma_char (n k : ℕ) :
  Grp.{u} n k ≃ Σ(B : pconntype.{u} (k.-1)), Σ(X : ptrunctype.{u} n), X ≃* Ω[k] B :=
begin
  fapply equiv.MK,
  { intro G, exact ⟨B G, G, e G⟩ },
  { intro v, exact Grp.mk v.2.1 v.1 v.2.2 },
  { intro v, induction v with v₁ v₂, induction v₂, reflexivity },
  { intro G, induction G, reflexivity },
end

definition Grp_equiv (n k : ℕ) : [n;k]Grp ≃ (n+k)-Type*[k.-1] :=
Grp.sigma_char n k ⬝e
sigma_equiv_of_is_embedding_left_contr
  ptruncconntype.to_pconntype
  (is_embedding_ptruncconntype_to_pconntype (n+k) (k.-1))
  begin
    intro X,
    apply is_trunc_equiv_closed_rev -2,
    { apply sigma_equiv_sigma_right, intro B',
      refine _ ⬝e (ptrunctype_eq_equiv B' (ptrunctype.mk (Ω[k] X) !is_trunc_loopn_nat pt))⁻¹ᵉ,
      assert lem : Π(A : n-Type*) (B : Type*) (H : is_trunc n B),
        (A ≃* B) ≃ (A ≃* (ptrunctype.mk B H pt)),
      { intro A B'' H, induction B'', reflexivity },
      apply lem }
  end
  begin
    intro B' H, apply fiber.mk (ptruncconntype.mk B' (is_trunc_B (Grp.mk H.1 B' H.2)) pt _),
    induction B' with G' B' e', reflexivity
  end

definition Grp_equiv_pequiv {n k : ℕ} (G : [n;k]Grp) : Grp_equiv n k G ≃* B G :=
by reflexivity

definition Grp_eq_equiv {n k : ℕ} (G H : [n;k]Grp) : (G = H :> [n;k]Grp) ≃ (B G ≃* B H) :=
eq_equiv_fn_eq_of_equiv (Grp_equiv n k) _ _ ⬝e !ptruncconntype_eq_equiv

definition Grp_eq {n k : ℕ} {G H : [n;k]Grp} (e : B G ≃* B H) : G = H :=
(Grp_eq_equiv G H)⁻¹ᵉ e

/- similar properties for [∞;k]Grp -/

definition InfGrp.sigma_char (k : ℕ) :
  InfGrp.{u} k ≃ Σ(B : pconntype.{u} (k.-1)), Σ(X : pType.{u}), X ≃* Ω[k] B :=
begin
  fapply equiv.MK,
  { intro G, exact ⟨iB G, G, ie G⟩ },
  { intro v, exact InfGrp.mk v.2.1 v.1 v.2.2 },
  { intro v, induction v with v₁ v₂, induction v₂, reflexivity },
  { intro G, induction G, reflexivity },
end

definition InfGrp_equiv (k : ℕ) : [∞;k]Grp ≃ Type*[k.-1] :=
InfGrp.sigma_char k ⬝e
@sigma_equiv_of_is_contr_right _ _
  (λX, is_trunc_equiv_closed_rev -2 (sigma_equiv_sigma_right (λB', !pType_eq_equiv⁻¹ᵉ)))

definition InfGrp_equiv_pequiv {k : ℕ} (G : [∞;k]Grp) : InfGrp_equiv k G ≃* iB G :=
by reflexivity

definition InfGrp_eq_equiv {k : ℕ} (G H : [∞;k]Grp) : (G = H :> [∞;k]Grp) ≃ (iB G ≃* iB H) :=
eq_equiv_fn_eq_of_equiv (InfGrp_equiv k) _ _ ⬝e !pconntype_eq_equiv

definition InfGrp_eq {k : ℕ} {G H : [∞;k]Grp} (e : iB G ≃* iB H) : G = H :=
(InfGrp_eq_equiv G H)⁻¹ᵉ e

-- maybe to do: ωGrp ≃ Σ(X : spectrum), is_sconn n X

/- Constructions -/
definition Decat (G : [n+1;k]Grp) : [n;k]Grp :=
Grp.mk (ptrunctype.mk (ptrunc n G) _ pt) (pconntype.mk (ptrunc (n + k) (B G)) _ pt)
  abstract begin
    refine ptrunc_pequiv_ptrunc n (e G) ⬝e* _,
    symmetry, exact !loopn_ptrunc_pequiv_nat
  end end

definition Disc (G : [n;k]Grp) : [n+1;k]Grp :=
Grp.mk (ptrunctype.mk G (show is_trunc (n.+1) G, from _) pt) (B G) (e G)

definition Decat_adjoint_Disc (G : [n+1;k]Grp) (H : [n;k]Grp) :
  ppmap (B (Decat G)) (B H) ≃* ppmap (B G) (B (Disc H)) :=
pmap_ptrunc_pequiv (n + k) (B G) (B H)

definition Decat_adjoint_Disc_natural {G G' : [n+1;k]Grp} {H H' : [n;k]Grp}
  (eG : B G' ≃* B G) (eH : B H ≃* B H') :
  psquare (Decat_adjoint_Disc G H)
          (Decat_adjoint_Disc G' H')
          (ppcompose_left eH ∘* ppcompose_right (ptrunc_functor _ eG))
          (ppcompose_left eH ∘* ppcompose_right eG) :=
sorry

definition Decat_Disc (G : [n;k]Grp) : Decat (Disc G) = G :=
Grp_eq !ptrunc_pequiv

definition InfDecat (n : ℕ) (G : [∞;k]Grp) : [n;k]Grp :=
Grp.mk (ptrunctype.mk (ptrunc n G) _ pt) (pconntype.mk (ptrunc (n + k) (iB G)) _ pt)
  abstract begin
    refine ptrunc_pequiv_ptrunc n (ie G) ⬝e* _,
    symmetry, exact !loopn_ptrunc_pequiv_nat
  end end

definition InfDisc (n : ℕ) (G : [n;k]Grp) : [∞;k]Grp :=
InfGrp.mk G (B G) (e G)

definition InfDecat_adjoint_InfDisc (G : [∞;k]Grp) (H : [n;k]Grp) :
  ppmap (B (InfDecat n G)) (B H) ≃* ppmap (iB G) (iB (InfDisc n H)) :=
pmap_ptrunc_pequiv (n + k) (iB G) (B H)

/- To do: naturality -/

definition InfDecat_InfDisc (G : [n;k]Grp) : InfDecat n (InfDisc n G) = G :=
Grp_eq !ptrunc_pequiv

definition Deloop (G : [n;k+1]Grp) : [n+1;k]Grp :=
have is_conn k (B G), from is_conn_pconntype (B G),
have is_trunc (n + (k + 1)) (B G), from is_trunc_B G,
have is_trunc ((n + 1) + k) (B G), from transport (λ(n : ℕ), is_trunc n _) (succ_add n k)⁻¹ this,
Grp.mk (ptrunctype.mk (Ω[k] (B G)) !is_trunc_loopn_nat pt)
  (pconntype.mk (B G) !is_conn_of_is_conn_succ pt)
  (pequiv_of_equiv erfl idp)

definition Loop (G : [n+1;k]Grp) : [n;k+1]Grp :=
Grp.mk (ptrunctype.mk (Ω G) !is_trunc_loop_nat pt)
  (connconnect k (B G))
  (loop_pequiv_loop (e G) ⬝e* (loopn_connect k (B G))⁻¹ᵉ*)

definition Deloop_adjoint_Loop (G : [n;k+1]Grp) (H : [n+1;k]Grp) :
  ppmap (B (Deloop G)) (B H) ≃* ppmap (B G) (B (Loop H)) :=
(connect_intro_pequiv _ !is_conn_pconntype)⁻¹ᵉ* /- still a sorry here -/

definition Loop_Deloop (G : [n;k+1]Grp) : Loop (Deloop G) = G :=
Grp_eq (connect_pequiv (is_conn_pconntype (B G)))

/- to do: adjunction, and Loop ∘ Deloop = id -/

definition Forget (G : [n;k+1]Grp) : [n;k]Grp :=
have is_conn k (B G), from !is_conn_pconntype,
Grp.mk G (pconntype.mk (Ω (B G)) !is_conn_loop pt)
  abstract begin
    refine e G ⬝e* !loopn_succ_in
  end end

definition Stabilize (G : [n;k]Grp) : [n;k+1]Grp :=
have is_conn k (susp (B G)), from !is_conn_susp,
have Hconn : is_conn k (ptrunc (n + k + 1) (susp (B G))), from !is_conn_ptrunc,
Grp.mk (ptrunctype.mk (ptrunc n (Ω[k+1] (susp (B G)))) _ pt)
  (pconntype.mk (ptrunc (n+k+1) (susp (B G))) Hconn pt)
  abstract begin
    refine !loopn_ptrunc_pequiv⁻¹ᵉ* ⬝e* _,
    apply loopn_pequiv_loopn,
    exact ptrunc_change_index !of_nat_add_of_nat _
  end end

/- to do: adjunction -/

definition ωForget (k : ℕ) (G : [n;ω]Grp) : [n;k]Grp :=
have is_trunc (n + k) (oB G k), from _,
have is_trunc n (Ω[k] (oB G k)), from !is_trunc_loopn_nat,
Grp.mk (ptrunctype.mk (Ω[k] (oB G k)) _ pt) (oB G k) (pequiv_of_equiv erfl idp)

definition nStabilize (H : k ≤ l) (G : Grp.{u} n k) : Grp.{u} n l :=
begin
  induction H with l H IH, exact G, exact Stabilize IH
end

lemma Stabilize_pequiv (H : k ≥ n + 2) (G : [n;k]Grp) : B G ≃* Ω (B (Stabilize G)) :=
sorry

theorem stabilization (H : k ≥ n + 2) : is_equiv (@Stabilize n k) :=
sorry

definition ωGrp.mk_le {n : ℕ} (k₀ : ℕ)
  (B : Π⦃k : ℕ⦄, k₀ ≤ k → (n+k)-Type*[k.-1])
  (e : Π⦃k : ℕ⦄ (H : k₀ ≤ k), B H ≃* Ω (B (le.step H))) : [n;ω]Grp :=
sorry

/- for l ≤ k we want to define it as Ω[k-l] (B G),
   for H : l ≥ k we want to define it as nStabilize H G -/

definition ωStabilize_of_le (H : k ≥ n + 2) (G : [n;k]Grp) : [n;ω]Grp :=
ωGrp.mk_le k (λl H', Grp_equiv n l (nStabilize H' G))
             (λl H', Stabilize_pequiv (le.trans H H') (nStabilize H' G))

definition ωStabilize (G : [n;k]Grp) : [n;ω]Grp :=
ωStabilize_of_le !le_max_left (nStabilize !le_max_right G)

/- to do: adjunction (and ωStabilize ∘ ωForget =?= id) -/

end higher_group
