## Week 7

Why are ceramics brittle?\
Different atoms in the crystal structure so harder to deform, and covalent/ionic bonding stronger than metallic bonding.

What is responsible for plastic deformation?\
Movement of dislocations.

Diffusion requires what?\
Need a defect for atom to move into, and sufficient energy to break bonds and distort lattice.

What's the difference between vacancy and interstitial diffusion?\
Vacancy diffusion is where a host/substitutional atom can move into a vacancy. Interstitial diffusion is where a small atom moves into interstitial space. This happens faster because smaller atoms are more mobile.

When diffusing along grain boundaries/dislocations or through vacancies, which pathway is faster and why?\
Grain boundary and dislocation diffusion are fast diffusion pathways because the atoms can be channelled along the sides. However, there's only 1 hole in a vacancy so only 1 can move.

## Week 8

Why does austenite have a higher weight fraction of carbon compared to ferrite?\
Austenite has a FCC crystal structure and ferrite has a BCC crystal structure. FCC has more space than BCC so carbon can fit interstitially more easily. 

What happens when steel at eutectoid composition is cooled?\
The steel first starts out as austenite. At the eutectoid temperature, the austenite starts transforming into ferrite and cementite within grain boundaries. As temperature decreases, the solubility of C in ferrite decreases, pushing C out of ferrite and thickening the cementite layers. This thickens cementite plates in pearlite and is diffusion-controlled (fast T drop means fine structure because less time for C to diffuse).

Compare and contrast diffusive and displacive phase transformations.\
Diffusive phase transformations are caused by diffusion, requiring T > 0.3Tm to 0.4Tm. Atoms diffuse from site to site, moving between 1 atom spacing and 0.1mm. This can change the composition of the phases present. Speed is strongly dependent on temperature (since it's diffusion-controlled), and the extent of the transformation is dependent on temperature and time.\
On the other hand, displacive phase transformations are caused by atoms breaking and forming atomic bonds, so atoms move very small distances in precise sequences. This is not diffusion-controlled so it can happen at any temperature, but the composition cannot change because there is no time for diffusion. Speed is very rapid, but extent is only temperature-dependent.

Describe the microstructure of martensite and bainite.\
Martensite's microstructure has needle-like grains where C atoms are trapped inside the matrix because there is no time for diffusion. Volume increases from austenite to martensite cause strains in the matrix, increasing hardness.\
Bainite's microstructure has fine cementite layers (similar to eutectic matrix formation) formed when C diffuses out of ferrite. 

Why is the rate of transformation to pearlite faster at low temperatures?\
At low temperatures, austenite (parent) is more thermodynamically unstable, which is the driving force for the transformation.

## Week 9

Define ductility.\
Ductility describes the amount of plastic deformation sustained at failure.

Are FCC, BCC and HCP crystal structures typically ductile or brittle? Why?\
Plastic deformation is a result of dislocation motion through slip planes - the densest planes of atoms within the unit cell. Since FCC and HCP are quite close-packed, the critical amount of shear stress to propagate dislocations is quite low compared to that of BCC (this is temperature-dependent though). HCP has a low amount (3) of slip systems, followed by FCC (12) and BCC (48). This combination of slip system number and critical shear stress typically makes HCP brittle and FCC ductile; BCC's ductility depends on temperature.

Explain the process of work-hardening.\
There are compressive and tensile strains surrounding edges of dislocations. Dislocations close to each other impede the motion of other dislocations, so by deliberately introducing plastic deformation we increase dislocation density which results in an increased stress required for further deformation.

What are some disadvantages to work-hardening?\
If we keep work-hardening the material, we make it very strong but brittle; further deformation during service would cause fracture. Elongated grains from rolling introduce anisotropic properties: stress *parallel* to rolling direction results in high strength and low ductility, but stress *perpendicular* to rolling direction results in low strength and high ductility. The material can fail well below the estimated limit if it is loaded in the wrong direction.

Why do grain boundaries act as a barrier to dislocations?\
Crystals at grain boundaries change orientation, and slip planes are discontinuous at grain boundaries.

Explain the process of annealing.\
We want to reduce the brittleness and anisotropy of heavily cold-worked materials. Note that strain energy in lattice $\Delta E \approx \rho G b^2$, where $\rho$ is dislocation density, $G$ is shear modulus and $b$ is the Burgers vector. Reducing dislocation density reduces lattice strain, which is the purpose of the recovery phase. At elevated temperatures, dislocations of opposite direction move and cancel each other out, reducing the total strain energy. \
After recovery, we leave the material at the recrystallisation temperature (0.3-0.5Tm) for some time, which forms new *strain-free* equiaxed (width = height) grains starting off as small nuclei, like the solidification process. This happens because of the difference in energy between strained and unstrained regions of the lattice. Note that since the difference in energy drives the process, we need a minimum cold work percentage to enable recrystallisation, usually around 10%.\
Grain boundaries have higher energy than the inside of the grains, so by leaving the material at elevated temperatures, atoms diffuse over the boundaries increasing grain size. This decreases the total energy (thermodynamically favourable).

What do we require of a material for it to be precipitation hardened?\
We need a high solubility of 1 phase in another, and a rapidly decreasing solubility limit while reducing temperature.

How do precipitates form when precipitation hardening?\
We first heat the metal up so that only one phase is present - let's call it alpha and the other phase theta. This is called *solution treatment*.\
Cooling the material slowly at this stage leads to theta precipitates forming at grain boundaries due to the higher energy. However, we now *quench* the metal forming a supersaturated solid solution, where the secondary atoms are now trapped within the alpha grains. This is where we want them to be, instead of at the boundaries.\
Now, we just need to allow a bit of diffusion by increasing temperature, enough to fully form the precipitates within the grains, but not enough for the secondary atoms to diffuse to the grain boundaries. This is called *aging*. We shouldn't increase T high enough that we're in the single phase region of the phase diagram; this is back to where we started.

What does it mean for a material to be overaged in the context of precipitation hardening, and why is it bad?\
The aging process starts off with a supersaturated solid solution. Using Al and Cu as an example where Cu is the secondary atom, Cu gathers in small discs in the solution called GP zones. Then, as temperature is raised to start aging, Cu starts to diffuse forming distinct particles. It first passes through the theta'' phase which is coherent with the matrix (lattice bonds pass through the zone, no disruptions), then intermediary theta' phase, then just normal theta which is incoherent. Particle size increases with time.\
Yield stress increases between the development of GP zones and theta'' because of coherency stress associated with the strain created while the particles are growing coherently.\
If the precipitates are small (theta''), dislocations just cut through. New surface area on the cut gives more energy, so this increases the yield stress. However, if the precipitates become too big, dislocations loop around them and simply bypass. This is called bowing and reduces the yield stress in comparison to theta''. Also, there is now more space between precipitates so not as many particles interfere with dislocation motion.\
Because of this, we only want to age the material up to the optimal point where theta'' precipitates are created. Letting theta' and theta precipitates form is called overaging which decreases the yield stress. Note that overaging can occur during service if the alloy is already at the optimal aging level and experiences elevated temperatures. Thus, for welded structures, don't pick an alloy which is already at the optimal level, as welding will age the metal further.

What is the difference between precipitation hardening and solid solution strengthening?\
Both inhibit dislocation motion, but precipitation hardening is when you use a *supersaturated* solid solution to trap the secondary atom and form precipitates, whereas solid solution strengthening is when everything remains in the single phase region and you use substitutional/interstitial defects to add strain into the lattice.

## Week 10

