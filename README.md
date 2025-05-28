# Habit Builder 🌱

A wellness-focused blockchain application for building positive habits, tracking your wellness journey, and earning NFT badges that celebrate your commitment to personal growth.

## Overview

Habit Builder transforms personal wellness into a rewarding blockchain experience. Start new habits, track your progress, and earn wellness badges that permanently record your journey towards a healthier lifestyle.

## Features

### 💪 Core Functionality
- **Start Habits**: Create new habits with detailed routine descriptions
- **Track Habits**: Mark habits as successfully tracked
- **Stop Habits**: Remove habits that no longer serve you
- **Adjust Habits**: Modify habit details as your routine evolves

### 🏆 Wellness Badges (NFT Rewards)
Earn motivational NFT badges:
- **First Step** - Track your first habit
- **Committed 10** - Complete 10 habits
- **Dedicated 50** - Complete 50 habits
- **Wellness Master** - Complete 100 habits

### 📊 Wellness Journey Tracking
- Total habits started
- Habits successfully tracked
- Current active habits
- Wellness achievements earned

## Smart Contract Functions

### Public Functions

#### `start-habit`
```clarity
(start-habit (habit-name (string-utf8 256)) (routine-details (string-utf8 1024)))
```
Begin tracking a new habit with name and routine details.

#### `track-habit`
```clarity
(track-habit (habit-id uint))
```
Mark a habit as successfully tracked and check for badge eligibility.

#### `stop-habit`
```clarity
(stop-habit (habit-id uint))
```
Remove a habit from your active tracking list.

#### `adjust-habit`
```clarity
(adjust-habit (habit-id uint) (habit-name (string-utf8 256)) (routine-details (string-utf8 1024)))
```
Modify the details of an existing habit.

### Read-Only Functions

#### `check-habit`
```clarity
(check-habit (habit-id uint) (participant principal))
```
View details of a specific habit.

#### `view-journey`
```clarity
(view-journey (participant principal))
```
Check a participant's overall wellness journey statistics.

#### `has-wellness-badge`
```clarity
(has-wellness-badge (participant principal) (badge-name (string-ascii 50)))
```
Verify if a participant has earned a specific wellness badge.

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for participation

### Installation
```bash
git clone https://github.com/sheidheda/habit-builder
cd habit-builder
clarinet integrate
```

### Testing
```bash
clarinet test
```

### Deployment
```bash
clarinet deployments generate --testnet
clarinet deployments apply -p deployments/testnet.plan.yaml
```

## Usage Example

```clarity
;; Start a new habit
(contract-call? .habit-builder start-habit 
    u"Morning Meditation" 
    u"10 minutes of mindfulness meditation every morning at 7 AM before breakfast")

;; Track habit completion
(contract-call? .habit-builder track-habit u0)

;; View your wellness journey
(contract-call? .habit-builder view-journey tx-sender)
```

## Architecture

### Data Management
- **Habits Map**: Stores habit details with participant-specific access
- **Participant Journey Map**: Tracks wellness statistics
- **Wellness Achievements Map**: Records NFT badges earned

### Privacy & Security
- Personal habit data remains private to each participant
- Habits cannot be tracked multiple times
- Input validation ensures data integrity

## Wellness Framework

### Habit Lifecycle
1. **Start** - Define a new positive habit
2. **Active** - Work on building the routine
3. **Track** - Mark successful completion
4. **Adjust** - Evolve as needed

### Badge System
Wellness badges are automatically minted as NFTs when you reach milestones. These serve as permanent reminders of your dedication to personal growth and can be shared as inspiration with others.

## Wellness Categories

### Supported Habit Types
- 🧘 **Mindfulness**: Meditation, breathing exercises
- 🏃 **Fitness**: Exercise routines, activity goals
- 🥗 **Nutrition**: Healthy eating habits
- 😴 **Sleep**: Sleep hygiene practices
- 📚 **Learning**: Daily reading, skill development
- 💧 **Hydration**: Water intake tracking

## Community Features

### Share Your Journey
- Export your wellness statistics
- Showcase earned badges
- Inspire others with your progress

### Privacy First
- Your detailed habit data remains private
- Only share what you choose to share
- Complete control over your wellness data

## Mobile App Integration

```javascript
// Example mobile app integration
const habitBuilder = new HabitBuilderSDK({
  network: 'mainnet',
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.habit-builder'
});

// Start tracking a habit
await habitBuilder.startHabit({
  name: "Daily Walk",
  routine: "30-minute walk in nature every evening"
});

// Track completion
await habitBuilder.trackHabit(habitId);
```

## Wellness Resources

- **Habit Formation Guide**: Best practices for building lasting habits
- **Community Forum**: Connect with other wellness enthusiasts
- **Expert Advice**: Access to wellness coaches and advisors

## Contributing

Join us in building a healthier world! See our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: [docs.habitbuilder.wellness](https://docs.habitbuilder.wellness)
- Community: [community.habitbuilder.wellness](https://community.habitbuilder.wellness)
- Instagram: [@HabitBuilderApp](https://instagram.com/habitbuilderapp)
