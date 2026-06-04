import Foundation

/// The complete offline content catalog. All data is compiled into the binary
/// so the app is fully functional in airplane mode with zero network access.
///
/// Built lazily and cached as `shared` for instant repeated access.
@MainActor
final class RSContentLibrary {
    static let shared = RSContentLibrary()

    let lessons: [RSLesson]
    let techniques: [RSTechnique]
    let programs: [RSTrainingProgram]
    let quiz: [RSQuizQuestion]
    let scenarios: [RSTacticalScenario]
    let sportsScience: [RSScienceModule]
    let legends: [RSLegend]

    private init() {
        lessons = RSContentLibrary.buildLessons()
        techniques = RSContentLibrary.buildTechniques()
        programs = RSContentLibrary.buildPrograms()
        quiz = RSContentLibrary.buildQuiz()
        scenarios = RSContentLibrary.buildScenarios()
        sportsScience = RSContentLibrary.buildScience()
        legends = RSContentLibrary.buildLegends()
    }

    func lessons(for discipline: RSDiscipline) -> [RSLesson] {
        lessons.filter { $0.discipline == discipline }.sorted { $0.tier < $1.tier }
    }

    func techniques(for discipline: RSDiscipline) -> [RSTechnique] {
        techniques.filter { $0.discipline == discipline }
    }

    /// True when a lesson should be locked for the given progress + entitlements.
    func isLessonLocked(_ lesson: RSLesson, unlockedTier: Int, ownsPack: (RSSubscriptionID) -> Bool) -> Bool {
        if lesson.tier > unlockedTier { return true }
        if let pack = lesson.requiredPack, !ownsPack(pack) { return true }
        return false
    }

    /// Lessons available given unlocked tier and a pack-ownership predicate.
    func availableLessons(unlockedTier: Int, ownsPack: (RSSubscriptionID) -> Bool) -> [RSLesson] {
        lessons.filter { !isLessonLocked($0, unlockedTier: unlockedTier, ownsPack: ownsPack) }
    }

    // MARK: - Lessons

    private static func buildLessons() -> [RSLesson] {
        [
            RSLesson(id: "box_stance", discipline: .boxing,
                     title: "The Orthodox Stance",
                     summary: "Your foundation. Everything—power, defense, mobility—starts here.",
                     overview: "Your stance is the platform every punch, slip, and step is built on. A balanced, mobile stance lets you generate power, defend instantly, and move in any direction without losing structure. Master it before anything else—weak punches and sloppy footwork almost always trace back to a broken stance.",
                     keyPoints: [
                        "Feet shoulder-width, lead foot forward, weight split roughly 50/50.",
                        "Hands high: rear hand on the chin, lead hand floating at eye level.",
                        "Elbows tucked to protect the body; chin slightly down.",
                        "Stay on the balls of your feet—never flat, never crossed."
                     ],
                     drills: [
                        "Hold your stance in front of a mirror for 60 seconds, checking alignment.",
                        "Shadow-shift forward, back, and laterally while keeping your base intact.",
                        "Drop into stance from relaxed standing 20 times to build muscle memory."
                     ],
                     commonMistakes: [
                        "Feet too narrow or too wide—both destroy balance.",
                        "Letting the rear hand drift off the chin.",
                        "Standing flat-footed instead of springy on the balls of the feet."
                     ],
                     proTip: "If a light shove knocks you off balance, your stance is wrong—reset your base.",
                     tier: 1, durationMinutes: 8),

            RSLesson(id: "box_jab", discipline: .boxing,
                     title: "Mastering the Jab",
                     summary: "The most important punch in boxing—measuring stick, shield, and setup.",
                     overview: "The jab is the most-used punch in boxing and the key that unlocks everything else. It measures distance, disrupts rhythm, creates openings, and keeps you safe. A sharp, fast jab thrown from a tight guard is the signature of an educated fighter.",
                     keyPoints: [
                        "Extend straight from the chin, rotating the fist to land with the knuckles.",
                        "The lead shoulder rises to protect the chin as the arm extends.",
                        "Snap it back instantly along the same line—don't drop it.",
                        "Use it to control distance before committing to power shots."
                     ],
                     drills: [
                        "Three rounds of jab-only shadow boxing: form, then speed, then doubles.",
                        "Jab a hanging tennis ball to sharpen accuracy and timing.",
                        "Pair every jab with a small step to train distance control."
                     ],
                     commonMistakes: [
                        "Telegraphing by loading the shoulder first.",
                        "Dropping the hand on the way back.",
                        "Pushing the punch instead of snapping it."
                     ],
                     proTip: "Throw it like flicking water off your fingertips—relaxed until the instant of impact.",
                     tier: 1, durationMinutes: 10, xpReward: 60),

            RSLesson(id: "box_footwork", discipline: .boxing,
                     title: "Footwork & Ring Generalship",
                     summary: "You hit harder, avoid more, and dictate the fight by controlling position.",
                     overview: "Footwork is the engine of boxing. It positions you to land cleanly, removes you from danger, and lets you decide where the fight happens. Power without position is wasted—great footwork multiplies everything else you do.",
                     keyPoints: [
                        "Step with the foot nearest your direction of travel first.",
                        "Never bring your feet together—keep your base at all times.",
                        "Cut angles: pivot off the lead foot to exit the line of attack.",
                        "Pressure forward in straight lines; escape on angles."
                     ],
                     drills: [
                        "Two rounds shadow boxing moving only on angles—never straight back.",
                        "Pivot off the lead foot after every combination to a new angle.",
                        "Use a floor ladder or tape for quick, controlled steps."
                     ],
                     commonMistakes: [
                        "Crossing the feet and destroying your base.",
                        "Retreating in straight lines onto incoming shots.",
                        "Bouncing aimlessly and wasting energy."
                     ],
                     proTip: "Pressure straight, escape on angles—the corner is for your opponent, not you.",
                     tier: 2, durationMinutes: 12, xpReward: 70),

            RSLesson(id: "box_combos", discipline: .boxing,
                     title: "Building Combinations",
                     summary: "Strings of punches that flow from balance and open new targets.",
                     overview: "Combinations are how punches become fights. Flowing strings of strikes overwhelm defenses, open new targets, and score in bunches. The secret is balance: every punch must return you to a position from which the next one is just as powerful.",
                     keyPoints: [
                        "Every punch should return you to balance to throw the next.",
                        "Mix levels: head, then body, then head.",
                        "The 1-2 (jab-cross) is the backbone of every combination.",
                        "Finish combinations with footwork to reset or escape."
                     ],
                     drills: [
                        "Drill the 1-2-3 (jab-cross-hook) until it flows without thought.",
                        "Three bag rounds mixing head-body-head.",
                        "End every combination with a pivot or step-off."
                     ],
                     commonMistakes: [
                        "Arm-punching the later shots once balance is lost.",
                        "Throwing the same predictable combination.",
                        "Forgetting defense between punches."
                     ],
                     proTip: "Land, then leave—exit before the counter comes.",
                     tier: 3, durationMinutes: 14, xpReward: 80, requiredPack: .eliteFighterPack),

            RSLesson(id: "mt_clinch", discipline: .muayThai,
                     title: "The Muay Thai Clinch",
                     summary: "Control the head and posture to deliver knees and off-balance opponents.",
                     overview: "The clinch is Muay Thai's defining range and where many fights are won. By controlling your opponent's head and posture you deliver knees, off-balance for sweeps, and drain their will. Clinch mastery turns a striker into a complete Nak Muay.",
                     keyPoints: [
                        "Lock hands behind the neck, forearms pressing in—never interlace fingers.",
                        "Pull the head down while keeping your own posture tall.",
                        "Control creates openings for knees up the center.",
                        "Swim your hands inside to win the inner position."
                     ],
                     drills: [
                        "Pummel for inside control with a partner for three minutes.",
                        "Knee-from-clinch reps on the bag, alternating sides.",
                        "Posture battle: stay tall while breaking your partner down."
                     ],
                     commonMistakes: [
                        "Interlacing the fingers behind the neck (weak and dangerous).",
                        "Letting your own posture break forward.",
                        "Fighting for grips without using them to attack."
                     ],
                     proTip: "Win the inside position first—hands inside theirs—then everything opens up.",
                     tier: 3, durationMinutes: 13, xpReward: 75),

            RSLesson(id: "mt_teep", discipline: .muayThai,
                     title: "The Teep (Push Kick)",
                     summary: "Muay Thai's jab—a range-controlling, rhythm-breaking front kick.",
                     overview: "The teep, or push kick, is the Muay Thai equivalent of the jab. It controls range, interrupts pressure, breaks rhythm, and sets up heavier weapons. A well-timed teep stops an aggressive opponent in their tracks.",
                     keyPoints: [
                        "Drive the knee up first, then extend through the ball of the foot.",
                        "Push through the target rather than snapping like a karate kick.",
                        "Use it to interrupt forward pressure and reset distance.",
                        "Recover the foot quickly to avoid catches and sweeps."
                     ],
                     drills: [
                        "Teep the bag focusing on driving the knee up first.",
                        "Balance teeps: throw and recover without setting the foot down.",
                        "Hold distance with the teep as a partner advances."
                     ],
                     commonMistakes: [
                        "Snapping it like a karate kick instead of pushing through.",
                        "Leaving the foot out to be caught.",
                        "Leaning too far back and losing balance."
                     ],
                     proTip: "Knee up first, then extend—push through the target, don't tap it.",
                     tier: 2, durationMinutes: 10),

            RSLesson(id: "kb_roundhouse", discipline: .kickboxing,
                     title: "The Roundhouse Kick",
                     summary: "Rotational power delivered through the shin to legs, body, or head.",
                     overview: "The roundhouse kick delivers rotational power to the legs, body, or head and is a cornerstone of kickboxing. Thrown with the shin and driven by full hip rotation, it's one of the most damaging strikes in combat sports.",
                     keyPoints: [
                        "Pivot the support foot fully so the hips can rotate over.",
                        "Strike with the shin, not the foot, for durability and power.",
                        "Swing the same-side arm down to add torque and protect the head.",
                        "Re-chamber or step through—never leave the leg hanging."
                     ],
                     drills: [
                        "Slow-motion roundhouse reps focusing on full hip rotation.",
                        "Pivot drill: turn the support foot fully before contact.",
                        "Bag rounds alternating low, body, and head kicks."
                     ],
                     commonMistakes: [
                        "Striking with the foot instead of the shin.",
                        "Failing to pivot the base foot, killing power.",
                        "Leaving the head unguarded during the kick."
                     ],
                     proTip: "Swing the leg like a baseball bat—through the target, not at it.",
                     tier: 2, durationMinutes: 11),

            RSLesson(id: "wr_double", discipline: .wrestling,
                     title: "The Double-Leg Takedown",
                     summary: "Change levels, penetrate, and finish—wrestling's bread and butter.",
                     overview: "The double-leg is wrestling's signature takedown and a vital skill across all combat sport. Change levels, penetrate deep, and drive—done well, it puts your opponent on the mat before they can react.",
                     keyPoints: [
                        "Change levels by bending the knees, not the waist.",
                        "Penetrate with a deep lead-leg step between the opponent's feet.",
                        "Drive the shoulder into the hips while gripping behind the knees.",
                        "Finish by turning the corner or lifting and tripping."
                     ],
                     drills: [
                        "Penetration-step drills across the mat with a deep lead step.",
                        "Level-change reps: drop the hips, not the head, on a cue.",
                        "Corner-turn finishes against a stationary partner."
                     ],
                     commonMistakes: [
                        "Bending at the waist instead of the knees.",
                        "Shooting from too far away.",
                        "Dropping the head down and exposing a guillotine."
                     ],
                     proTip: "Level change first, then penetrate—never reach for the legs from upright.",
                     tier: 2, durationMinutes: 12, xpReward: 70),

            RSLesson(id: "wr_sprawl", discipline: .wrestling,
                     title: "The Sprawl (Takedown Defense)",
                     summary: "The primary defense against shots—drop your hips and kill the legs.",
                     overview: "If the double-leg is the sword, the sprawl is the shield. Reacting early and dropping your hips onto an opponent's shot is the foundation of takedown defense and keeps strikers on their feet.",
                     keyPoints: [
                        "Shoot your legs back and drop your hips onto the opponent's shoulders.",
                        "Underhook or cross-face to control the head and posture.",
                        "Circle away from their power side to come around to the back.",
                        "React early—the sprawl fails if you're late."
                     ],
                     drills: [
                        "Sprawl on a whistle or cue to train reaction speed.",
                        "Partner shot defense: sprawl and circle to the back.",
                        "Cross-face and underhook control reps from the sprawl."
                     ],
                     commonMistakes: [
                        "Reacting late—the sprawl must beat the shot.",
                        "Keeping the hips high instead of dropping them.",
                        "Failing to control the head after sprawling."
                     ],
                     proTip: "Hips heavy, head controlled, then circle to the back off their power side.",
                     tier: 2, durationMinutes: 9),

            RSLesson(id: "bjj_guard", discipline: .bjj,
                     title: "The Closed Guard",
                     summary: "From your back, control and attack using legs, hips, and grips.",
                     overview: "Guard is the heart of jiu-jitsu—the ability to fight, attack, and win from your back. The closed guard controls your opponent's posture and base while you threaten sweeps and submissions, turning a defensive position into an offensive one.",
                     keyPoints: [
                        "Ankles crossed behind the opponent's back, knees squeezing.",
                        "Break posture with grips and hip movement.",
                        "Never lie flat—angle your hips to create attacking angles.",
                        "Threaten sweeps and submissions simultaneously."
                     ],
                     drills: [
                        "Hip-up and angle drills to create attacking angles.",
                        "Grip-fighting: break posture and control sleeve/collar.",
                        "Flow between sweep and submission threats to keep them reacting."
                     ],
                     commonMistakes: [
                        "Lying flat instead of angling the hips.",
                        "Crossing the ankles loosely with no real control.",
                        "Attacking before controlling posture."
                     ],
                     proTip: "Never lie flat—angle your hips and make them defend two threats at once.",
                     tier: 4, durationMinutes: 14, xpReward: 85, requiredPack: .eliteFighterPack),

            RSLesson(id: "bjj_mount", discipline: .bjj,
                     title: "Escaping the Mount",
                     summary: "Composure and the right mechanics beat panic every time.",
                     overview: "Being mounted is one of the worst positions in grappling, but panic makes it worse. Calm, technical escapes—bridging and shrimping—reliably recover guard or reverse position. Survival comes first, then the escape.",
                     keyPoints: [
                        "Trap an arm and the same-side leg, then bridge over that shoulder.",
                        "Use the elbow-escape (shrimp) to recover guard when bridging fails.",
                        "Protect your neck first—survival precedes escape.",
                        "Create space with the bridge, then move hips, never the reverse."
                     ],
                     drills: [
                        "Trap-and-roll (upa) escape reps from mount.",
                        "Elbow-escape (shrimp) drill to recover guard.",
                        "Frame-and-survive: maintain elbow frames under control."
                     ],
                     commonMistakes: [
                        "Bridging without trapping the arm and leg first.",
                        "Pushing with the arms and getting them attacked.",
                        "Moving the hips before creating space with the bridge."
                     ],
                     proTip: "Protect the neck, bridge to make space, then move your hips—never the reverse.",
                     tier: 4, durationMinutes: 13, xpReward: 85),

            RSLesson(id: "judo_kuzushi", discipline: .judo,
                     title: "Kuzushi — Breaking Balance",
                     summary: "No throw works without first destroying the opponent's balance.",
                     overview: "Kuzushi—breaking balance—is the principle that makes every judo throw possible. By directing your opponent onto the edges of their feet at the right moment, even a smaller player can throw a larger one with ease.",
                     keyPoints: [
                        "Use grips to direct the opponent onto the edges of their feet.",
                        "Time off-balancing to their movement, not against it.",
                        "Learn the eight directions of unbalancing through the gi.",
                        "Throw into the direction they are already falling."
                     ],
                     drills: [
                        "Grip-and-pull drills to feel the eight directions of unbalancing.",
                        "Time kuzushi to a partner's step.",
                        "Uchikomi (fit-in reps) emphasizing the off-balance before the throw."
                     ],
                     commonMistakes: [
                        "Trying to muscle the throw without off-balancing first.",
                        "Pulling against the opponent's movement instead of with it.",
                        "Static grips that telegraph your intent."
                     ],
                     proTip: "Throw into the direction they're already falling—time it to their movement.",
                     tier: 3, durationMinutes: 12),

            RSLesson(id: "mma_ranges", discipline: .mma,
                     title: "The Four Ranges of MMA",
                     summary: "Striking, clinch, takedown, and ground—win by controlling transitions.",
                     overview: "MMA is the art of managing four ranges—striking, clinch, takedown, and ground—and the dangerous transitions between them. The complete fighter forces opponents into the range where they hold the advantage and punishes them in the gaps.",
                     keyPoints: [
                        "Each range has its own offense, defense, and dominant positions.",
                        "The danger lives in transitions—level changes and clinch entries.",
                        "Force opponents into the range where you hold the advantage.",
                        "Threats in one range open opportunities in another."
                     ],
                     drills: [
                        "Range-transition drills: strike to clinch to takedown entries.",
                        "Defensive-transition reps: defend the level change off strikes.",
                        "Positional sparring isolating one transition at a time."
                     ],
                     commonMistakes: [
                        "Thinking in one range only and freezing in transitions.",
                        "Standing square in the pocket like a pure boxer.",
                        "Neglecting takedown defense while striking."
                     ],
                     proTip: "Danger lives in the transitions—threats in one range open another.",
                     tier: 5, durationMinutes: 16, xpReward: 100, requiredPack: .eliteFighterPack),

            RSLesson(id: "def_headmove", discipline: .defense,
                     title: "Defensive Head Movement",
                     summary: "Slips, rolls, and pulls that make you hard to hit and ready to counter.",
                     overview: "Head movement makes you hard to hit and ready to hurt. Slips, rolls, and pulls move your head off the line of attack while keeping your eyes on the target and loading a counter. Defense and offense become one motion.",
                     keyPoints: [
                        "Slip by rotating at the waist—move the head off the centerline, not down.",
                        "Roll under hooks by bending the knees and rotating, hands up.",
                        "Every defensive movement should load a counter.",
                        "Keep your eyes on the opponent throughout—never close them."
                     ],
                     drills: [
                        "Slip-rope or string drill: slip side to side under a line.",
                        "Roll under a partner's looping hook, hands up.",
                        "Slip-and-counter: every slip followed by an immediate return shot."
                     ],
                     commonMistakes: [
                        "Ducking straight down into uppercuts.",
                        "Closing the eyes or looking away.",
                        "Defending without loading a counter."
                     ],
                     proTip: "Slip to hit, not just to survive—every movement sets up a counter.",
                     tier: 1, durationMinutes: 11, xpReward: 60),

            RSLesson(id: "cond_energy", discipline: .conditioning,
                     title: "Energy Systems for Fighters",
                     summary: "Train the right system for the demands of your sport and rounds.",
                     overview: "Understanding energy systems lets you train the right engine for combat. Fights are intermittent—explosive bursts separated by recovery—so fighters need all three systems, built in the right order, to last and stay sharp.",
                     keyPoints: [
                        "Alactic (10s bursts), glycolytic (rounds), and aerobic (recovery base).",
                        "Build an aerobic base first—it powers recovery between exchanges.",
                        "Interval work mirrors the start-stop nature of combat.",
                        "Periodize: base, then intensity, then sport-specific peaking."
                     ],
                     drills: [
                        "Zone 2 aerobic work (30–40 min) to build the recovery base.",
                        "Round-format intervals: 3 min hard / 1 min easy ×5.",
                        "Short alactic bursts: 10s max effort, full recovery, repeat."
                     ],
                     commonMistakes: [
                        "Only doing steady-state cardio and never training intensity.",
                        "Skipping the aerobic base and gassing in sparring.",
                        "No periodization—random hard sessions every day."
                     ],
                     proTip: "Build the aerobic base first—it powers recovery between every exchange.",
                     tier: 1, durationMinutes: 13, xpReward: 65),

            RSLesson(id: "cond_recovery", discipline: .conditioning,
                     title: "Recovery & Adaptation",
                     summary: "You don't get stronger when you train—you adapt when you recover.",
                     overview: "Training is the stimulus; recovery is where you actually adapt and improve. Fighters who recover deliberately—sleep, load management, nutrition—get better faster and get hurt less than those who only grind.",
                     keyPoints: [
                        "Sleep is the single most powerful recovery tool—aim for 7–9 hours.",
                        "Manage load: hard days must be balanced by easy days.",
                        "Active recovery clears fatigue faster than total rest.",
                        "Track readiness; persistent soreness and poor sleep signal overreach."
                     ],
                     drills: [
                        "Set a fixed sleep window and protect 7–9 hours.",
                        "Plan hard/easy day alternation across the week.",
                        "Post-session: five minutes of slow nasal breathing to down-regulate."
                     ],
                     commonMistakes: [
                        "Treating every session as maximal effort.",
                        "Ignoring sleep and expecting to adapt.",
                        "No deload weeks across a training block."
                     ],
                     proTip: "If resting heart rate is up and sleep is poor, back off—that's overreach talking.",
                     tier: 2, durationMinutes: 12),

            RSLesson(id: "box_counter", discipline: .boxing,
                     title: "Counter-Punching",
                     summary: "Make opponents pay for every punch they throw.",
                     overview: "Counter-punching turns an opponent's offense into your opportunity. By reading, slipping, or rolling an incoming strike and answering instantly, you score cleanly while they're committed and exposed. It's the hallmark of a mature, patient fighter.",
                     keyPoints: [
                        "Read the opponent's habits—every fighter telegraphs something.",
                        "Defend and counter as one motion, not two.",
                        "The pull-counter: lean back from a jab, then fire the cross.",
                        "Counter into the opening their punch creates, not a random target."
                     ],
                     drills: [
                        "Partner feeds a jab; you slip outside and counter with a cross.",
                        "Pull-counter reps: pull from the jab and return straight down the middle.",
                        "Shadow box visualizing an incoming punch before each counter."
                     ],
                     commonMistakes: [
                        "Countering late, after the exchange is already over.",
                        "Loading up and telegraphing the counter.",
                        "Backing straight up instead of countering off a slip."
                     ],
                     proTip: "Don't chase the counter—let it come to you as their punch falls short.",
                     tier: 3, durationMinutes: 13, xpReward: 80),

            RSLesson(id: "str_power", discipline: .striking,
                     title: "Generating Knockout Power",
                     summary: "Real power is a full-body chain, not arm strength.",
                     overview: "Knockout power doesn't come from the arm—it comes from the ground, up through the legs and hips, into rotation, and finally out the fist or shin. Sequencing that kinetic chain is what separates a pusher from a puncher.",
                     keyPoints: [
                        "Power starts at the feet—drive from the ground up.",
                        "Rotate the hips and torso; the limb is the last link.",
                        "Stay relaxed until the moment of impact, then snap tight.",
                        "Land with proper alignment so force transfers instead of leaking."
                     ],
                     drills: [
                        "Slow-motion reps focusing on foot-hip-fist sequencing.",
                        "Heavy-bag rounds prioritizing torque over speed.",
                        "Medicine-ball rotational throws to train hip drive."
                     ],
                     commonMistakes: [
                        "Arm-punching with no hip rotation.",
                        "Tensing the whole motion, which kills speed.",
                        "Lifting the heel late and breaking the chain."
                     ],
                     proTip: "Stay loose like a whip—rigid arms are slow and weak.",
                     tier: 2, durationMinutes: 12),

            RSLesson(id: "str_hook", discipline: .striking,
                     title: "The Lead Hook",
                     summary: "A short, brutal arc that lands where opponents don't see it.",
                     overview: "The lead hook is one of the most dangerous strikes in combat sport—short, fast, and thrown on a horizontal arc that slips around an opponent's guard. Generated by hip and pivot rather than arm, it can end a fight from close range.",
                     keyPoints: [
                        "Pivot the lead foot and turn the hip into the shot.",
                        "Keep the elbow bent near 90 degrees, level with the fist.",
                        "Glue the rear hand to the chin to guard the counter.",
                        "Throw it off the jab or after slipping to find the angle."
                     ],
                     drills: [
                        "Pivot-and-hook reps on the bag, focusing on hip turn.",
                        "1-2-hook combination until the pivot becomes automatic.",
                        "Hook off a slip to train the defense-to-offense transition."
                     ],
                     commonMistakes: [
                        "Swinging the arm with no pivot (a wide haymaker).",
                        "Dropping the opposite hand on the throw.",
                        "Over-rotating and losing balance."
                     ],
                     proTip: "Turn it like slamming a door with your hip—the arm just goes along for the ride.",
                     tier: 2, durationMinutes: 11),

            RSLesson(id: "kb_switch", discipline: .kickboxing,
                     title: "The Switch Kick",
                     summary: "Switch your stance to fire a lead-leg power kick.",
                     overview: "The switch kick lets you throw a powerful roundhouse with your lead leg by quickly switching your feet, generating the torque of a rear kick from the front. It's fast, deceptive, and bridges distance beautifully.",
                     keyPoints: [
                        "Switch the feet with a small hop, hips loading as you do.",
                        "Throw immediately out of the switch—don't pause.",
                        "Pivot the new support foot fully toward the target.",
                        "Strike with the shin and recover to stance."
                     ],
                     drills: [
                        "Switch-step reps without kicking to groove the footwork.",
                        "Switch kick on the bag, alternating body and head.",
                        "Disguise the entry by pairing a teep with the switch kick."
                     ],
                     commonMistakes: [
                        "Pausing after the switch, telegraphing the kick.",
                        "Switching too wide and losing balance.",
                        "Forgetting to pivot the support foot."
                     ],
                     proTip: "Switch and fire as one beat—the hop and the kick are a single motion.",
                     tier: 3, durationMinutes: 12),

            RSLesson(id: "judo_osoto", discipline: .judo,
                     title: "Osoto Gari — Major Outer Reap",
                     summary: "Off-balance backward, then reap the leg out from under them.",
                     overview: "Osoto gari is a foundational judo throw: break the opponent's balance to their rear corner, then reap their supporting leg out with your own. Timing and kuzushi matter far more than strength.",
                     keyPoints: [
                        "Break balance to the opponent's right-rear corner first.",
                        "Step your support foot deep alongside theirs.",
                        "Reap the leg with a powerful backward swing of your hamstring.",
                        "Drive their head and shoulders down with your gripping arms."
                     ],
                     drills: [
                        "Uchikomi (fit-ins) for the entry and balance break.",
                        "Reap slowly against a crash pad with a partner.",
                        "Combine a forward feint with the backward osoto entry."
                     ],
                     commonMistakes: [
                        "Reaping before breaking balance—they just step out.",
                        "Standing upright with no head or shoulder control.",
                        "A weak grip that lets them posture and counter."
                     ],
                     proTip: "Take their balance first—if you have to muscle the reap, the kuzushi failed.",
                     tier: 3, durationMinutes: 13),

            RSLesson(id: "mma_gnp", discipline: .mma,
                     title: "Ground and Pound",
                     summary: "Strike from dominant top position while staying defensively sound.",
                     overview: "Ground and pound is striking from top position—turning positional dominance into damage. The key is balancing offense with base and posture so you never trade control for a wild strike.",
                     keyPoints: [
                        "Secure a dominant position before you start striking.",
                        "Post and base so you can't be swept or submitted.",
                        "Mix strikes with posture to open the guard and create space.",
                        "Use strikes to set up submissions, and vice versa."
                     ],
                     drills: [
                        "Posture-and-strike reps from inside the guard on a dummy.",
                        "Mount control with light contact, maintaining base.",
                        "Transition drills: strike to open guard, then pass."
                     ],
                     commonMistakes: [
                        "Lunging into strikes and getting swept.",
                        "Posturing so high you lose control.",
                        "Forgetting submission threats while striking."
                     ],
                     proTip: "Control first, damage second—never trade position for one big punch.",
                     tier: 5, durationMinutes: 15),

            RSLesson(id: "def_blocking", discipline: .defense,
                     title: "Blocking & Parrying",
                     summary: "The high guard and parries that buy time and openings.",
                     overview: "Not every shot can be slipped—blocking and parrying are your reliable, low-risk defenses. A tight high guard absorbs strikes, while parries redirect them and open instant counters. They're the safety net beneath all head movement.",
                     keyPoints: [
                        "Keep a tight high guard: gloves at the temples, elbows in.",
                        "Parry the jab with a small, economical hand movement—don't reach.",
                        "Catch the cross on the rear glove and return fire immediately.",
                        "Stay compact; blocking with wide arms creates gaps."
                     ],
                     drills: [
                        "Partner jabs lightly; you parry and return a jab.",
                        "Shell-guard reps absorbing hooks on the forearms.",
                        "Catch-and-counter the cross for three rounds."
                     ],
                     commonMistakes: [
                        "Reaching for parries and exposing the centerline.",
                        "Flaring the elbows and opening the body.",
                        "Blocking passively without countering."
                     ],
                     proTip: "Parry small—a tiny redirect beats a big swat that opens you up.",
                     tier: 1, durationMinutes: 10),

            RSLesson(id: "bjj_pass", discipline: .bjj,
                     title: "Passing the Guard",
                     summary: "Get past the legs to dominant control without getting swept.",
                     overview: "Passing the guard converts a neutral position into dominance. Whether you pass with pressure or speed, the principles are the same: control the hips, beat the legs, and consolidate before advancing.",
                     keyPoints: [
                        "Control the hips—an opponent who can't move their hips can't guard.",
                        "Keep your own posture and base throughout the pass.",
                        "Beat the legs first, then clear them past your hips.",
                        "Consolidate the new position before chasing the next step."
                     ],
                     drills: [
                        "Knee-cut pass reps against an open guard.",
                        "Stack-and-pass pressure drills with a partner.",
                        "Pass-and-consolidate: pause to secure side control each rep."
                     ],
                     commonMistakes: [
                        "Rushing past the legs and getting recaptured.",
                        "Losing posture and getting swept or submitted.",
                        "Passing without controlling the hips first."
                     ],
                     proTip: "Pin the hips first—legs are dangerous, but hips are the engine.",
                     tier: 4, durationMinutes: 14, xpReward: 85)
        ]
    }

    // MARK: - Techniques

    private static func buildTechniques() -> [RSTechnique] {
        [
            RSTechnique(id: "t_jab", discipline: .boxing, name: "Jab", category: "Punch",
                        mechanics: [
                            "Start in stance, hands high.",
                            "Extend the lead arm straight from the chin.",
                            "Rotate the fist; lead shoulder rises to guard the chin.",
                            "Snap the punch back along the same line."
                        ],
                        commonMistakes: ["Dropping the hand on the return", "Telegraphing by loading the shoulder"],
                        coachingCue: "Throw it like you're flicking water off your fingertips—fast and relaxed."),
            RSTechnique(id: "t_cross", discipline: .boxing, name: "Cross", category: "Punch",
                        mechanics: [
                            "Drive off the rear foot, pivoting the heel outward.",
                            "Rotate the hips and torso toward the target.",
                            "Extend the rear hand straight down the centerline.",
                            "Keep the lead hand up to guard; return to stance."
                        ],
                        commonMistakes: ["Punching with the arm only", "Lifting the lead hand away from the chin"],
                        coachingCue: "Power comes from the ground up—feet, hips, then hand."),
            RSTechnique(id: "t_roundkick", discipline: .muayThai, name: "Roundhouse Kick", category: "Kick",
                        mechanics: [
                            "Step the lead foot slightly out to open the hips.",
                            "Pivot the support foot fully toward the target.",
                            "Swing the leg through, striking with the shin.",
                            "Rotate the hips over; recover or step through."
                        ],
                        commonMistakes: ["Kicking with the foot instead of the shin", "Not pivoting the base foot"],
                        coachingCue: "Swing the leg like a baseball bat—through the target, not at it."),
            RSTechnique(id: "t_double", discipline: .wrestling, name: "Double-Leg", category: "Takedown",
                        mechanics: [
                            "Change levels by bending the knees.",
                            "Penetrate with a deep lead step.",
                            "Grip behind both knees, shoulder into the hips.",
                            "Drive through and turn the corner to finish."
                        ],
                        commonMistakes: ["Bending at the waist", "Shooting from too far away"],
                        coachingCue: "Level change first, then penetrate—never reach for the legs."),
            RSTechnique(id: "t_armbar", discipline: .bjj, name: "Armbar from Guard", category: "Submission",
                        mechanics: [
                            "Control a wrist and break posture from closed guard.",
                            "Angle your hips out to the side of the trapped arm.",
                            "Swing the leg over the head, clamping the knees.",
                            "Raise the hips while controlling the wrist to finish."
                        ],
                        commonMistakes: ["Crossing the feet", "Letting the elbow slip past the hips"],
                        coachingCue: "Pinch your knees together—the arm can't escape what it can't slide through."),
            RSTechnique(id: "t_hook", discipline: .boxing, name: "Lead Hook", category: "Punch",
                        mechanics: [
                            "From stance, weight settled over the lead foot.",
                            "Pivot the lead foot and turn the hip toward the target.",
                            "Swing the bent arm horizontally, elbow level with the fist.",
                            "Return the hand to the chin and reset your base."
                        ],
                        commonMistakes: ["Swinging wide with no pivot", "Dropping the rear hand"],
                        coachingCue: "Turn it like slamming a door with your hip."),
            RSTechnique(id: "t_teep", discipline: .muayThai, name: "Teep (Push Kick)", category: "Kick",
                        mechanics: [
                            "Lift the knee of the kicking leg high.",
                            "Point the support foot slightly outward for balance.",
                            "Extend through the ball of the foot, pushing into the target.",
                            "Snap the foot back quickly and return to stance."
                        ],
                        commonMistakes: ["Snapping like a karate kick", "Leaving the foot out to be caught"],
                        coachingCue: "Knee up first, then push through—don't just tap the surface.")
        ]
    }

    // MARK: - Programs

    private static func buildPrograms() -> [RSTrainingProgram] {
        [
            RSTrainingProgram(
                id: "prog_foundation",
                title: "Foundation: First 7 Days",
                focus: "Stance, jab, footwork, and conditioning base",
                level: "Beginner",
                days: [
                    RSTrainingDay(id: "f1", label: "Day 1 — Stance & Guard", blocks: [
                        RSTrainingBlock(id: "f1a", name: "Mobility flow", detail: "Hips, shoulders, ankles", minutes: 8, kind: .mobility),
                        RSTrainingBlock(id: "f1b", name: "Stance holds & shifts", detail: "Shadow stance work", minutes: 15, kind: .technique),
                        RSTrainingBlock(id: "f1c", name: "Easy aerobic", detail: "Jump rope / shadow", minutes: 12, kind: .conditioning)
                    ]),
                    RSTrainingDay(id: "f2", label: "Day 2 — The Jab", blocks: [
                        RSTrainingBlock(id: "f2a", name: "Warmup", detail: "Dynamic + light shadow", minutes: 8, kind: .warmup),
                        RSTrainingBlock(id: "f2b", name: "Jab repetition", detail: "Form, then speed", minutes: 18, kind: .technique),
                        RSTrainingBlock(id: "f2c", name: "Core circuit", detail: "Planks, rotations", minutes: 10, kind: .conditioning)
                    ]),
                    RSTrainingDay(id: "f3", label: "Day 3 — Active Recovery", blocks: [
                        RSTrainingBlock(id: "f3a", name: "Mobility & breathing", detail: "Down-regulate", minutes: 20, kind: .recovery)
                    ])
                ],
                requiredPack: nil
            ),
            RSTrainingProgram(
                id: "prog_engine",
                title: "Fight Engine: Conditioning Block",
                focus: "Build the gas tank for hard sparring rounds",
                level: "Intermediate",
                days: [
                    RSTrainingDay(id: "e1", label: "Day 1 — Aerobic Base", blocks: [
                        RSTrainingBlock(id: "e1a", name: "Zone 2 work", detail: "Conversational pace", minutes: 35, kind: .conditioning),
                        RSTrainingBlock(id: "e1b", name: "Mobility", detail: "Cooldown", minutes: 10, kind: .mobility)
                    ]),
                    RSTrainingDay(id: "e2", label: "Day 2 — Intervals", blocks: [
                        RSTrainingBlock(id: "e2a", name: "Warmup", detail: "Progressive", minutes: 10, kind: .warmup),
                        RSTrainingBlock(id: "e2b", name: "Round intervals", detail: "3 min on / 1 min off ×6", minutes: 24, kind: .conditioning),
                        RSTrainingBlock(id: "e2c", name: "Recovery walk", detail: "Flush", minutes: 8, kind: .recovery)
                    ])
                ],
                requiredPack: .championAcademyPack
            )
        ]
    }

    // MARK: - Quiz

    private static func buildQuiz() -> [RSQuizQuestion] {
        [
            RSQuizQuestion(id: "q1", discipline: .boxing,
                           prompt: "What is the primary purpose of the jab?",
                           options: ["Knockout power", "Controlling distance and setting up", "Defense only", "Showmanship"],
                           correctIndex: 1,
                           explanation: "The jab measures distance, disrupts rhythm, and sets up power shots."),
            RSQuizQuestion(id: "q2", discipline: .wrestling,
                           prompt: "When shooting a double-leg, you should change levels by…",
                           options: ["Bending at the waist", "Bending the knees", "Leaning the head down", "Jumping"],
                           correctIndex: 1,
                           explanation: "Bending the knees keeps posture and power; bending at the waist invites a sprawl."),
            RSQuizQuestion(id: "q3", discipline: .conditioning,
                           prompt: "Which energy system should a fighter build first?",
                           options: ["Alactic", "Aerobic base", "Glycolytic only", "None—just spar"],
                           correctIndex: 1,
                           explanation: "An aerobic base powers recovery between explosive exchanges."),
            RSQuizQuestion(id: "q4", discipline: .muayThai,
                           prompt: "In Muay Thai you strike the roundhouse primarily with the…",
                           options: ["Toes", "Instep", "Shin", "Heel"],
                           correctIndex: 2,
                           explanation: "The shin is durable and delivers more mass than the foot."),
            RSQuizQuestion(id: "q5", discipline: .bjj,
                           prompt: "A common, dangerous mistake while applying an armbar is…",
                           options: ["Pinching the knees", "Crossing your feet", "Controlling the wrist", "Angling your hips"],
                           correctIndex: 1,
                           explanation: "Crossing the feet loosens knee pressure and lets the arm slip free."),
            RSQuizQuestion(id: "q6", discipline: .defense,
                           prompt: "When parrying a jab, you should…",
                           options: ["Reach out to swat it away", "Make a small, economical redirect", "Close your eyes", "Step straight back"],
                           correctIndex: 1,
                           explanation: "A small parry keeps you covered; reaching opens the centerline."),
            RSQuizQuestion(id: "q7", discipline: .striking,
                           prompt: "Knockout power is generated primarily by…",
                           options: ["Arm strength alone", "The kinetic chain from the ground up", "Holding your breath", "Leaning back"],
                           correctIndex: 1,
                           explanation: "Power sequences from feet to hips to the limb—the arm is the last link."),
            RSQuizQuestion(id: "q8", discipline: .judo,
                           prompt: "Before attempting any throw you must first…",
                           options: ["Grip harder", "Break the opponent's balance (kuzushi)", "Drop to your knees", "Push straight ahead"],
                           correctIndex: 1,
                           explanation: "No throw works without kuzushi—breaking balance comes first.")
        ]
    }

    // MARK: - Tactical Scenarios

    private static func buildScenarios() -> [RSTacticalScenario] {
        [
            RSTacticalScenario(
                id: "sc1",
                situation: "A taller opponent is keeping you on the end of their jab. You can't get inside. What's the soundest adjustment?",
                options: [
                    RSTacticalOption(id: "sc1a", text: "Walk straight forward behind a high guard", soundness: 35,
                                     feedback: "You'll eat jabs the whole way in. Straight-line pressure into a longer fighter is costly."),
                    RSTacticalOption(id: "sc1b", text: "Slip the jab and enter on an angle", soundness: 90,
                                     feedback: "Excellent. Taking the angle removes you from their power line and closes distance safely."),
                    RSTacticalOption(id: "sc1c", text: "Stay at range and out-jab them", soundness: 45,
                                     feedback: "Fighting a longer fighter at their range plays to their advantage.")
                ]
            ),
            RSTacticalScenario(
                id: "sc2",
                situation: "You're in your opponent's closed guard. They're controlling your posture. Priority?",
                options: [
                    RSTacticalOption(id: "sc2a", text: "Posture up and establish base before passing", soundness: 92,
                                     feedback: "Right. Posture and base come before any pass attempt."),
                    RSTacticalOption(id: "sc2b", text: "Immediately dive for a submission", soundness: 20,
                                     feedback: "Submissions from inside a controlled guard expose you to sweeps and attacks."),
                    RSTacticalOption(id: "sc2c", text: "Lie chest-to-chest to rest", soundness: 30,
                                     feedback: "That hands control to your opponent and feeds their attacks.")
                ]
            ),
            RSTacticalScenario(
                id: "sc3",
                situation: "Late in a hard round you're fading and your opponent smells it, stepping in aggressively. Soundest response?",
                options: [
                    RSTacticalOption(id: "sc3a", text: "Tie up in the clinch to steal a breather and reset", soundness: 85,
                                     feedback: "Smart. Clinching buys recovery time and disrupts their momentum."),
                    RSTacticalOption(id: "sc3b", text: "Stand and trade to prove you're not hurt", soundness: 20,
                                     feedback: "Ego trading while fatigued is how rounds get lost—or worse."),
                    RSTacticalOption(id: "sc3c", text: "Circle out and reset behind the jab", soundness: 78,
                                     feedback: "Solid—movement and the jab buy space without giving up control.")
                ]
            )
        ]
    }

    // MARK: - Sports Science Modules

    private static func buildScience() -> [RSScienceModule] {
        [
            RSScienceModule(id: "sci_energy", title: "Energy Systems",
                            icon: "bolt.heart.fill",
                            body: "Combat sport is intermittent: short, maximal bursts separated by lower-intensity recovery. The alactic system fuels ~10-second explosions, the glycolytic system carries sustained flurries, and the aerobic system governs how fast you recover between them. Train all three, but build the aerobic base first—it is the foundation of round-to-round durability.",
                            requiredPack: nil),
            RSScienceModule(id: "sci_recovery", title: "Recovery Science",
                            icon: "moon.zzz.fill",
                            body: "Adaptation happens during recovery, not training. Sleep drives hormonal repair and motor-skill consolidation. Manage weekly load with hard/easy alternation, use active recovery to clear metabolic byproducts, and monitor readiness markers—resting heart rate, sleep quality, and persistent soreness—to avoid overreaching.",
                            requiredPack: .championAcademyPack),
            RSScienceModule(id: "sci_mobility", title: "Mobility & Flexibility",
                            icon: "figure.flexibility",
                            body: "Mobility is usable range of motion under control. Fighters need supple hips for kicks and level changes, thoracic rotation for punching power, and resilient ankles and shoulders. Prioritize dynamic mobility before training and longer holds afterward.",
                            requiredPack: nil),
            RSScienceModule(id: "sci_nutrition", title: "Sports Nutrition Basics",
                            icon: "fork.knife",
                            body: "Fuel performance with adequate carbohydrate around hard sessions, sufficient protein for repair (roughly 1.6–2.2 g/kg/day), and consistent hydration. Avoid extreme weight cuts; gradual, planned weight management protects performance and health.",
                            requiredPack: .championAcademyPack),
            RSScienceModule(id: "sci_psych", title: "Combat Psychology",
                            icon: "brain.head.profile",
                            body: "Performance under pressure is trainable. Controlled breathing regulates arousal, pre-fight routines create consistency, and reframing nerves as readiness improves output. Discipline is built through repeatable systems, not motivation alone.",
                            requiredPack: nil)
        ]
    }

    // MARK: - Legends / Case Studies

    private static func buildLegends() -> [RSLegend] {
        [
            RSLegend(id: "leg_ali", name: "The Mover", discipline: .boxing,
                     lesson: "Footwork and distance management can neutralize raw power. Movement is defense and offense at once."),
            RSLegend(id: "leg_thai", name: "The Clinch Master", discipline: .muayThai,
                     lesson: "Dominating the clinch lets a fighter control pace, score, and break the opponent's will."),
            RSLegend(id: "leg_grappler", name: "The Submission Artist", discipline: .bjj,
                     lesson: "Patience and position before submission—technique conquers strength on the ground."),
            RSLegend(id: "leg_wrestler", name: "The Pressure Wrestler", discipline: .wrestling,
                     lesson: "Relentless level changes and top control break opponents physically and mentally.")
        ]
    }
}

/// A sports-science learning module (offline reference content).
struct RSScienceModule: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let icon: String
    let body: String
    /// Pack required to access this module; `nil` means free.
    let requiredPack: RSSubscriptionID?

    var isPremium: Bool { requiredPack != nil }
}

/// An anonymized case study capturing a champion archetype's core lesson.
struct RSLegend: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let discipline: RSDiscipline
    let lesson: String
}
