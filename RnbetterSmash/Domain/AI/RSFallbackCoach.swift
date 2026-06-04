import Foundation

/// Deterministic, fully offline coaching engine.
///
/// Used when Apple Foundation Models are unavailable, and as the simplified
/// system that keeps the chat functional after a free user hits their AI cap.
/// Matches the question against structured topic templates; always returns a
/// useful, educational answer—even for unclear input.
struct RSFallbackCoach: RSCoachEngine {

    func reply(to prompt: String, history: [RSCoachMessage]) async throws -> RSCoachReply {
        let text = Self.answer(for: prompt)
        return RSCoachReply(text: text, source: .localEngine)
    }

    /// Pure, synchronous lookup so it can be unit-tested and reused anywhere.
    static func answer(for prompt: String) -> String {
        let q = prompt.lowercased()

        for topic in topics where topic.matches(q) {
            return topic.answer
        }

        // Graceful handling of unclear / empty input.
        if q.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
            return unclearInputResponse
        }
        return genericResponse
    }

    // MARK: - Topic Templates

    private struct Topic {
        let keywords: [String]
        let answer: String
        func matches(_ q: String) -> Bool { keywords.contains { q.contains($0) } }
    }

    private static let topics: [Topic] = [
        Topic(keywords: ["jab"], answer: """
        Improving your jab comes down to mechanics, speed, and intent.

        Mechanics: extend straight from your chin, rotate the fist to land with the front two knuckles, and let your lead shoulder rise to protect your chin. Snap it back along the same line—never let it drop.

        Common mistakes: telegraphing by loading the shoulder, and lazily returning the hand.

        Drill: 3 rounds of jab-only shadow boxing. Round 1 focus on form, round 2 on speed, round 3 on doubling and feinting. Cue: "flick water off your fingertips." Keep it relaxed until impact.
        """),
        Topic(keywords: ["footwork", "foot work"], answer: """
        Footwork is how you control distance, angles, and balance.

        Principles: step with the foot nearest your direction first, never bring your feet together, and stay on the balls of your feet. Maintain your base at all times.

        Cutting angles: pivot off your lead foot to step off the opponent's centerline—now you can hit while they reset.

        Drill: shadow box moving only on angles for 2 rounds, then add pivots after every combination. Keep your weight centered so you can punch at any moment.
        """),
        Topic(keywords: ["conditioning", "cardio", "gas tank", "sparring conditioning", "endurance"], answer: """
        Conditioning for sparring is about repeat-effort capacity, not just running.

        Build the aerobic base first—it powers your recovery between exchanges. Then add interval work that mirrors fighting: 3 minutes hard, 1 minute easy, repeated.

        Sample week: 2 aerobic sessions (Zone 2, 30–40 min), 2 interval sessions (round-format), and skill sparring on separate days. Always pair hard days with easy days.

        Cue: condition the way you fight—explosive bursts with active recovery, not steady-state grinding.
        """),
        Topic(keywords: ["takedown", "double leg", "single leg", "wrestling"], answer: """
        Common wrestling takedowns every fighter should know:

        1. Double-leg: change levels by bending your knees, penetrate with a deep lead step, grip behind both knees, drive through and turn the corner.
        2. Single-leg: capture one leg, keep your head inside or out, and finish by running the pipe, lifting, or tripping.
        3. Body-lock / clinch takedowns: control the hips and off-balance.

        Key rule: level change before penetration—never reach for the legs from upright. Defend with an early sprawl: hips down, head control, circle to the back.
        """),
        Topic(keywords: ["reaction", "reflex", "reaction speed", "reaction time"], answer: """
        Reaction speed improves through perception training, not just fast hands.

        Methods:
        - Partner reaction drills: respond to a visual cue (a tap, a feint) with a set counter.
        - Reading patterns: learn an opponent's tells so you anticipate rather than react.
        - Reaction-ball and number-call drills to force quick decisions.
        - Sparring with constraints (defense only, counter only) trains live recognition.

        Recovery matters: reaction time degrades with fatigue and poor sleep. Sharp reactions require a rested nervous system.
        """),
        Topic(keywords: ["weekly", "structure", "schedule", "week", "plan training", "training week"], answer: """
        A balanced weekly structure for a developing fighter:

        - Mon: Technique + light skill work
        - Tue: Conditioning intervals + core
        - Wed: Active recovery (mobility, easy aerobic)
        - Thu: Technique + situational sparring
        - Fri: Strength + power
        - Sat: Hard sparring or open-mat rolling
        - Sun: Full rest

        Principles: alternate hard and easy days, never stack two maximal days, and protect at least one full rest day. Adjust volume to your recovery—progress is built on consistency, not punishment.
        """),
        Topic(keywords: ["recovery", "recover", "sore", "rest"], answer: """
        The most effective recovery methods, in order of impact:

        1. Sleep — 7–9 hours. Nothing else comes close for repair and skill consolidation.
        2. Load management — alternate hard and easy days; deload every few weeks.
        3. Active recovery — light movement clears fatigue faster than total rest.
        4. Nutrition & hydration — adequate protein and carbs around sessions.
        5. Down-regulation — slow breathing and mobility to shift out of fight-or-flight.

        Watch readiness markers: elevated resting heart rate, poor sleep, and lingering soreness mean back off.
        """),
        Topic(keywords: ["clinch"], answer: """
        The clinch (especially in Muay Thai) is about control and posture.

        Lock your hands behind the opponent's neck—forearms pressing in, never interlaced fingers. Pull their head down while keeping your own posture tall. Win the inside position by swimming your hands inside theirs.

        From control you can deliver knees up the center, off-balance for sweeps, or defend their offense. Drill the "pummeling" exchange to fight for inside control.
        """),
        Topic(keywords: ["kick", "roundhouse", "teep", "push kick"], answer: """
        For powerful, safe kicks:

        Roundhouse: pivot your support foot fully so your hips can rotate over, strike with the shin (not the foot), and swing your same-side arm down for torque. Re-chamber or step through—never leave the leg hanging.

        Teep (push kick): drive the knee up first, then extend through the ball of the foot, pushing through the target. Use it to control range and break rhythm.

        Cue: kick through the target like a baseball swing, not at it like a tap.
        """),
        Topic(keywords: ["guard", "submission", "bjj", "jiu", "mount", "armbar"], answer: """
        Ground fundamentals (BJJ):

        Position before submission—always. From closed guard, control posture, angle your hips, and threaten sweeps and submissions together. When escaping mount, protect your neck first, then bridge and shrimp to recover guard.

        For submissions like the armbar: control the wrist, pinch your knees, and never cross your feet. Patience and leverage beat strength every time.
        """),
        Topic(keywords: ["defense", "head movement", "slip", "defend", "block"], answer: """
        Defensive systems keep you in the fight and ready to counter.

        Layers of defense: distance (footwork), structure (guard), and reaction (slips, rolls, parries). Slip by rotating at the waist to move your head off the centerline—not straight down. Roll under hooks by bending the knees.

        Golden rule: every defensive movement should load a counter. Keep your eyes on the opponent the whole time.
        """)
    ]

    static let genericResponse = """
    Great question. Here's how to approach it like a coach:

    1. Master the fundamentals first—stance, balance, and breathing underpin everything.
    2. Drill the specific skill in isolation before adding speed or resistance.
    3. Identify the most common mistake and build a cue to avoid it.
    4. Apply it under light pressure, then progressively harder.
    5. Recover well—skill sticks when your nervous system is rested.

    Try the Learn and Train sections for a structured breakdown, and ask me a more specific question (e.g. "how do I improve my jab?") for detailed mechanics.
    """

    static let unclearInputResponse = """
    I didn't quite catch that. Try asking something specific like:
    • "How do I improve my jab?"
    • "How should I structure my training week?"
    • "What recovery methods work best?"

    I'm here to help you train smarter.
    """
}
