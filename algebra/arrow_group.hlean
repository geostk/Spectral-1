/-
Copyright (c) 2016-2017 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Ulrik Buchholtz

Various groups of maps. Most importantly we define a group structure
on trunc 0 (A →* Ω B) and the dependent version trunc 0 (ppi _ _),
which are used in the definition of cohomology.
-/

import algebra.group_theory ..pointed ..pointed_pi eq2
open pi pointed algebra group eq equiv is_trunc trunc susp
namespace group

  /- Group of dependent functions into a loop space -/
  definition ppi_mul [constructor] {A : Type*} {B : A → Type*} (f g : Π*a, Ω (B a)) : Π*a, Ω (B a) :=
  proof ppi.mk (λa, f a ⬝ g a) (respect_pt f ◾ respect_pt g ⬝ !idp_con) qed

  definition ppi_inv [constructor] {A : Type*} {B : A → Type*} (f : Π*a, Ω (B a)) : Π*a, Ω (B a) :=
  proof ppi.mk (λa, (f a)⁻¹ᵖ) (respect_pt f)⁻² qed

  definition inf_group_ppi [constructor] [instance] {A : Type*} (B : A → Type*) :
    inf_group (Π*a, Ω (B a)) :=
  begin
    fapply inf_group.mk,
    { exact ppi_mul },
    { intro f g h, apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, exact con.assoc (f a) (g a) (h a) },
      { symmetry, rexact eq_of_square (con2_assoc (respect_pt f) (respect_pt g) (respect_pt h)) }},
    { apply ppi_const },
    { intros f, apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, exact one_mul (f a) },
      { symmetry, apply eq_of_square, refine _ ⬝vp !ap_id, apply natural_square_tr }},
    { intros f, apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, exact mul_one (f a) },
      { reflexivity }},
    { exact ppi_inv },
    { intro f, apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, exact con.left_inv (f a) },
      { exact !con_left_inv_idp }},
  end

  definition group_trunc_ppi [constructor] [instance] {A : Type*} (B : A → Type*) :
    group (trunc 0 (Π*a, Ω (B a))) :=
  !trunc_group

  definition Group_trunc_ppi [reducible] [constructor] {A : Type*} (B : A → Type*) : Group :=
  Group.mk (trunc 0 (Π*a, Ω (B a))) _

  definition ab_inf_group_ppi [constructor] [instance] {A : Type*} (B : A → Type*) :
    ab_inf_group (Π*a, Ω (Ω (B a))) :=
  ⦃ab_inf_group, inf_group_ppi (λa, Ω (B a)), mul_comm :=
    begin
      intro f g, apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, exact eckmann_hilton (f a) (g a) },
      { symmetry, rexact eq_of_square (eckmann_hilton_con2 (respect_pt f) (respect_pt g)) }
    end⦄

  definition ab_group_trunc_ppi [constructor] [instance] {A : Type*} (B : A → Type*) :
    ab_group (trunc 0 (Π*a, Ω (Ω (B a)))) :=
  !trunc_ab_group

  definition AbGroup_trunc_ppi [reducible] [constructor] {A : Type*} (B : A → Type*) : AbGroup :=
  AbGroup.mk (trunc 0 (Π*a, Ω (Ω (B a)))) _

  definition trunc_ppi_isomorphic_pmap (A B : Type*)
    : Group.mk (trunc 0 (Π*(a : A), Ω B)) !trunc_group
      ≃g Group.mk (trunc 0 (A →* Ω B)) !trunc_group :=
  begin
    reflexivity,
    -- apply trunc_isomorphism_of_equiv (pppi_equiv_pmap A (Ω B)),
    -- intro h k, induction h with h h_pt, induction k with k k_pt, reflexivity
  end

  section

  universe variables u v

  variables {A : pType.{u}} {B : A → Type.{v}} {x₀ : B pt} {k l m : ppi B x₀}

  definition phomotopy_of_eq_homomorphism (p : k = l) (q : l = m)
    : phomotopy_of_eq (p ⬝ q) = phomotopy_of_eq p ⬝* phomotopy_of_eq q :=
  begin
    induction q, induction p, induction k with k q, induction q, reflexivity
  end

  protected definition ppi_mul_loop.lemma1 {X : Type} {x : X} (p q : x = x) (p_pt : idp = p) (q_pt : idp = q)
    : refl (p ⬝ q) ⬝ whisker_left p q_pt⁻¹ ⬝ p_pt⁻¹ = p_pt⁻¹ ◾ q_pt⁻¹ :=
  by induction p_pt; induction q_pt; reflexivity

  protected definition ppi_mul_loop.lemma2 {X : Type} {x : X} (p q : x = x) (p_pt : p = idp) (q_pt : q = idp)
    : refl (p ⬝ q) ⬝ whisker_left p q_pt ⬝ p_pt = p_pt ◾ q_pt :=
  by rewrite [-(inv_inv p_pt),-(inv_inv q_pt)]; exact ppi_mul_loop.lemma1 p q p_pt⁻¹ q_pt⁻¹

  definition ppi_mul_loop {h : Πa, B a} (f g : ppi.mk h idp ~* ppi.mk h idp) : f ⬝* g = ppi_mul f g :=
  begin
    apply ap (ppi.mk (λa, f a ⬝ g a)),
    apply ppi.rec_on f, intros f' f_pt, apply ppi.rec_on g, intros g' g_pt,
    clear f g, esimp at *, exact ppi_mul_loop.lemma2 (f' pt) (g' pt) f_pt g_pt
  end

  variable (k)

  definition trunc_ppi_loop_isomorphism_lemma
    : isomorphism.{(max u v) (max u v)}
      (Group.mk (trunc 0 (k = k)) (@trunc_group (k = k) !inf_group_loop))
      (Group.mk (trunc 0 (Π*(a : A), Ω (pType.mk (B a) (k a)))) !trunc_group) :=
  begin
    apply @trunc_isomorphism_of_equiv _ _ !inf_group_loop !inf_group_ppi (ppi_loop_equiv k),
    intro f g, induction k with k p, induction p,
    apply trans (phomotopy_of_eq_homomorphism f g),
    exact ppi_mul_loop (phomotopy_of_eq f) (phomotopy_of_eq g)
  end

  end

  definition trunc_ppi_loop_isomorphism {A : Type*} (B : A → Type*)
    : Group.mk (trunc 0 (Ω (Π*(a : A), B a))) !trunc_group
      ≃g Group.mk (trunc 0 (Π*(a : A), Ω (B a))) !trunc_group :=
  trunc_ppi_loop_isomorphism_lemma (ppi_const B)


  /- We first define the group structure on A →* Ω B (except for truncatedness).
     Instead of Ω B, we could also choose any infinity group. However, we need various 2-coherences,
     so it's easier to just do it for the loop space. -/
  definition pmap_mul [constructor] {A B : Type*} (f g : A →* Ω B) : A →* Ω B :=
  ppi_mul f g

  definition pmap_inv [constructor] {A B : Type*} (f : A →* Ω B) : A →* Ω B :=
  ppi_inv f

  /- we prove some coherences of the multiplication. We don't need them for the group structure,
    but they are used to show that cohomology satisfies the Eilenberg-Steenrod axioms -/
  definition ap1_pmap_mul {X Y : Type*} (f g : X →* Ω Y) :
    Ω→ (pmap_mul f g) ~* pmap_mul (Ω→ f) (Ω→ g) :=
  begin
    fapply phomotopy.mk,
    { intro p, esimp,
      refine ap1_gen_con_left (respect_pt f) (respect_pt f)
               (respect_pt g) (respect_pt g) p ⬝ _,
      refine !whisker_right_idp ◾ !whisker_left_idp2, },
    { refine !con.assoc ⬝ _,
      refine _ ◾ idp ⬝ _, rotate 1,
      rexact ap1_gen_con_left_idp (respect_pt f) (respect_pt g), esimp,
      refine !con.assoc ⬝ _,
      apply whisker_left, apply inv_con_eq_idp,
      refine !con2_con_con2 ⬝ ap011 concat2 _ _:
        refine eq_of_square (!natural_square ⬝hp !ap_id) ⬝ !con_idp }
  end

  definition pmap_mul_pcompose {A B C : Type*} (g h : B →* Ω C) (f : A →* B) :
    pmap_mul g h ∘* f ~* pmap_mul (g ∘* f) (h ∘* f) :=
  begin
    fapply phomotopy.mk,
    { intro p, reflexivity },
    { esimp, refine !idp_con ⬝ _, refine !con2_con_con2⁻¹ ⬝ whisker_right _ _,
      refine !ap_eq_ap011⁻¹ }
  end

  definition pcompose_pmap_mul {A B C : Type*} (h : B →* C) (f g : A →* Ω B) :
    Ω→ h ∘* pmap_mul f g ~* pmap_mul (Ω→ h ∘* f) (Ω→ h ∘* g) :=
  begin
    fapply phomotopy.mk,
    { intro p, exact ap1_con h (f p) (g p) },
    { refine whisker_left _ !con2_con_con2⁻¹ ⬝ _, refine !con.assoc⁻¹ ⬝ _,
      refine whisker_right _ (eq_of_square !ap1_gen_con_natural) ⬝ _,
      refine !con.assoc ⬝ whisker_left _ _, apply ap1_gen_con_idp }
  end

  definition loop_susp_intro_pmap_mul {X Y : Type*} (f g : susp X →* Ω Y) :
    loop_susp_intro (pmap_mul f g) ~* pmap_mul (loop_susp_intro f) (loop_susp_intro g) :=
  pwhisker_right _ !ap1_pmap_mul ⬝* !pmap_mul_pcompose

  definition inf_group_pmap [constructor] [instance] (A B : Type*) : inf_group (A →* Ω B) :=
  !inf_group_ppi

  definition group_trunc_pmap [constructor] [instance] (A B : Type*) : group (trunc 0 (A →* Ω B)) :=
  !trunc_group

  definition Group_trunc_pmap [reducible] [constructor] (A B : Type*) : Group :=
  Group.mk (trunc 0 (A →* Ω B)) _

  definition Group_trunc_pmap_homomorphism [constructor] {A A' B : Type*} (f : A' →* A) :
    Group_trunc_pmap A B →g Group_trunc_pmap A' B :=
  begin
    fapply homomorphism.mk,
    { apply trunc_functor, intro g, exact g ∘* f},
    { intro g h, induction g with g, induction h with h, apply ap tr,
      apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, reflexivity },
      { symmetry, refine _ ⬝ !idp_con⁻¹,
        refine whisker_right _ !ap_con_fn ⬝ _, apply con2_con_con2 }}
  end

  definition Group_trunc_pmap_isomorphism [constructor] {A A' B : Type*} (f : A' ≃* A) :
    Group_trunc_pmap A B ≃g Group_trunc_pmap A' B :=
  begin
    apply isomorphism.mk (Group_trunc_pmap_homomorphism f),
    apply @is_equiv_trunc_functor,
    exact to_is_equiv (pequiv_ppcompose_right f),
  end

  definition Group_trunc_pmap_isomorphism_refl (A B : Type*) (x : Group_trunc_pmap A B) :
    Group_trunc_pmap_isomorphism (pequiv.refl A) x = x :=
  begin
    induction x, apply ap tr, apply eq_of_phomotopy, apply pcompose_pid
  end

  definition Group_trunc_pmap_pid [constructor] {A B : Type*} (f : Group_trunc_pmap A B) :
    Group_trunc_pmap_homomorphism (pid A) f = f :=
  begin
    induction f with f, apply ap tr, apply eq_of_phomotopy, apply pcompose_pid
  end

  definition Group_trunc_pmap_pconst [constructor] {A A' B : Type*} (f : Group_trunc_pmap A B) :
    Group_trunc_pmap_homomorphism (pconst A' A) f = 1 :=
  begin
    induction f with f, apply ap tr, apply eq_of_phomotopy, apply pcompose_pconst
  end

  definition Group_trunc_pmap_pcompose [constructor] {A A' A'' B : Type*} (f : A' →* A)
    (f' : A'' →* A') (g : Group_trunc_pmap A B) : Group_trunc_pmap_homomorphism (f ∘* f') g =
    Group_trunc_pmap_homomorphism f' (Group_trunc_pmap_homomorphism f g) :=
  begin
    induction g with g, apply ap tr, apply eq_of_phomotopy, exact !passoc⁻¹*
  end

  definition Group_trunc_pmap_phomotopy [constructor] {A A' B : Type*} {f f' : A' →* A}
    (p : f ~* f') : @Group_trunc_pmap_homomorphism _ _ B f ~ Group_trunc_pmap_homomorphism f' :=
  begin
    intro g, induction g, exact ap tr (eq_of_phomotopy (pwhisker_left a p))
  end

  definition Group_trunc_pmap_phomotopy_refl {A A' B : Type*} (f : A' →* A)
    (x : Group_trunc_pmap A B) : Group_trunc_pmap_phomotopy (phomotopy.refl f) x = idp :=
  begin
    induction x,
    refine ap02 tr _,
    refine ap eq_of_phomotopy _ ⬝ !eq_of_phomotopy_refl,
    apply pwhisker_left_refl
  end

  definition ab_inf_group_pmap [constructor] [instance] (A B : Type*) :
    ab_inf_group (A →* Ω (Ω B)) :=
  ⦃ab_inf_group, inf_group_pmap A (Ω B), mul_comm :=
    begin
      intro f g, apply eq_of_phomotopy, fapply phomotopy.mk,
      { intro a, exact eckmann_hilton (f a) (g a) },
      { symmetry, rexact eq_of_square (eckmann_hilton_con2 (respect_pt f) (respect_pt g)) }
    end⦄

  definition ab_group_trunc_pmap [constructor] [instance] (A B : Type*) :
    ab_group (trunc 0 (A →* Ω (Ω B))) :=
  !trunc_ab_group

  definition AbGroup_trunc_pmap [reducible] [constructor] (A B : Type*) : AbGroup :=
  AbGroup.mk (trunc 0 (A →* Ω (Ω B))) _

  /- Group of dependent functions whose codomain is a group -/
  definition group_pi [instance] [constructor] {A : Type} (P : A → Type) [Πa, group (P a)] :
    group (Πa, P a) :=
  begin
    fapply group.mk,
    { apply is_trunc_pi },
    { intro f g a, exact f a * g a },
    { intros, apply eq_of_homotopy, intro a, apply mul.assoc },
    { intro a, exact 1 },
    { intros, apply eq_of_homotopy, intro a, apply one_mul },
    { intros, apply eq_of_homotopy, intro a, apply mul_one },
    { intro f a, exact (f a)⁻¹ },
    { intros, apply eq_of_homotopy, intro a, apply mul.left_inv }
  end

  definition Group_pi [constructor] {A : Type} (P : A → Group) : Group :=
  Group.mk (Πa, P a) _

  /- we use superscript in the following notation, because otherwise we can never write something
     like `Πg h : G, _` anymore -/

  notation `Πᵍ` binders `, ` r:(scoped P, Group_pi P) := r

  definition Group_pi_intro [constructor] {A : Type} {G : Group} {P : A → Group} (f : Πa, G →g P a)
    : G →g Πᵍ a, P a :=
  begin
    fconstructor,
    { intro g a, exact f a g },
    { intro g h, apply eq_of_homotopy, intro a, exact respect_mul (f a) g h }
  end

end group
