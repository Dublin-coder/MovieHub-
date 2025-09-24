# MovieHub 🎬

> A digital film community platform that tracks movie watching, rewards cinema engagement, and builds connections between film enthusiasts through blockchain technology

[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-purple)](https://stacks.co/)
[![Clarity](https://img.shields.io/badge/Smart_Contract-Clarity-blue)](https://clarity-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Cinema](https://img.shields.io/badge/Focus-Movies-red)](https://github.com/yourusername/moviehub)

## Overview

MovieHub transforms movie watching into a rewarding community experience by creating a decentralized platform where every film viewed, review written, and cinema discussion shared contributes to a thriving film community. Movie enthusiasts earn MovieHub Cinema Tokens (MCT) for logging watch sessions, writing thoughtful reviews, and contributing to the collective knowledge of cinema.

### Key Features

- **🎥 Movie Database** - Community-maintained film registry with detailed movie information
- **📝 Watch Logging** - Track your viewing experiences with ratings and personal notes
- **⭐ Review System** - Share detailed film critiques and discover community opinions
- **🏆 Cinema Milestones** - Recognition for movie watching accomplishments
- **👤 Viewer Profiles** - Personal cinema journey tracking with genre preferences
- **🎭 Genre Exploration** - Discover films across different categories and styles
- **💰 Cinema Rewards** - Token incentives for active community participation

## Getting Started

### Prerequisites

- [Clarinet CLI](https://github.com/hirosystems/clarinet) installed
- [Stacks Wallet](https://www.hiro.so/wallet) for blockchain interactions
- Node.js 16+ (for development and testing)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/moviehub-stacks
cd moviehub-stacks
```

2. Install dependencies
```bash
clarinet install
```

3. Run tests
```bash
clarinet test
```

4. Deploy to testnet
```bash
clarinet deploy --testnet
```

## Smart Contract Architecture

### Core Components

#### Token Economy (MCT)
- **Token Name**: MovieHub Cinema Token
- **Symbol**: MCT
- **Decimals**: 6
- **Max Supply**: 40,000 MCT
- **Philosophy**: Rewarding active film community participation and quality content creation

#### Cinema Ecosystem
- **Movie Database**: Community-curated film information with detailed metadata
- **Watch Tracking**: Personal viewing logs with ratings and viewing context
- **Review Platform**: In-depth film analysis and community discussion
- **Achievement System**: Milestone recognition for cinema exploration
- **Viewer Profiles**: Personalized film journey and preference tracking

### Reward Structure

| Activity | MCT Reward | Purpose |
|----------|------------|---------|
| Watch Session | 1.4 MCT | Logging movie viewing experience |
| Film Review | 2.6 MCT | Contributing detailed film analysis |
| Cinema Milestone | 8.5 MCT | Recognizing significant viewing achievements |

### Data Models

#### Viewer Profile
```clarity
{
  username: (string-ascii 24),
  favorite-genre: (string-ascii 12),    // "action", "comedy", "drama", "horror", "sci-fi"
  movies-watched: uint,
  reviews-written: uint,
  watchlist-items: uint,
  viewer-level: uint,                   // 1-5 cinema expertise progression
  join-date: uint
}
```

#### Movie Database
```clarity
{
  movie-title: (string-ascii 48),
  genre: (string-ascii 12),
  release-year: uint,
  runtime-minutes: uint,
  director: (string-ascii 24),
  submitter: principal,                 // Community contributor credit
  watch-count: uint,                    // Community viewing statistics
  average-rating: uint                  // Aggregated community rating (1-10)
}
```

#### Watch Session
```clarity
{
  movie-id: uint,
  viewer: principal,
  watch-rating: uint,                   // Personal rating (1-10)
  watch-location: (string-ascii 12),    // "theater", "home", "streaming"
  watch-notes: (string-ascii 96),      // Personal viewing observations
  watch-date: uint,
  recommended: bool                     // Auto-calculated for ratings 7+
}
```

## Core Functions

### Movie Management

#### `add-movie`
Contribute films to the community database
```clarity
(add-movie 
  "The Shawshank Redemption" 
  "drama" 
  u1994 
  u142 
  "Frank Darabont")
```

#### `log-watch`
Record your movie viewing experiences
```clarity
(log-watch 
  u1          ;; movie-id
  u9          ;; rating (1-10)
  "theater"   ;; viewing location
  "Incredible cinematography and powerful performances")
```

### Community Features

#### `write-review`
Share detailed film analysis with the community
```clarity
(write-review 
  u1 
  u9 
  "A masterpiece of storytelling that explores hope and redemption through exceptional character development and stunning visuals" 
  true) ;; spoiler-free flag
```

#### `upvote-review`
Support quality community reviews
```clarity
(upvote-review u1 reviewer-principal)
```

### Profile Customization

#### `update-favorite-genre`
Set your preferred film genre
```clarity
(update-favorite-genre "sci-fi")
```

#### `update-username`
Personalize your cinema community identity
```clarity
(update-username "CinemaEnthusiast")
```

### Achievement System

#### `claim-milestone`
Earn recognition for cinema accomplishments
```clarity
(claim-milestone "cinephile-25") ;; For watching 25+ movies
(claim-milestone "critic-12")    ;; For writing 12+ reviews
```

## Film Genres & Categories

### Supported Genres
- **Action**: High-energy films with exciting sequences
- **Comedy**: Humorous films designed to entertain
- **Drama**: Character-driven stories with emotional depth
- **Horror**: Films designed to frighten and create suspense
- **Sci-Fi**: Science fiction exploring futuristic concepts

### Viewing Locations
- **Theater**: Traditional cinema experience
- **Home**: Personal viewing environment
- **Streaming**: Online platform viewing

## Rating & Review System

### Rating Scale (1-10)
- **1-3**: Poor quality, not recommended
- **4-5**: Below average, watchable with reservations
- **6-7**: Good quality, enjoyable viewing experience
- **8-9**: Excellent film, highly recommended
- **10**: Masterpiece, exceptional in all aspects

### Review Quality Features
- **Spoiler-Free Toggle**: Protect other viewers from plot reveals
- **Community Upvoting**: Highlight helpful and insightful reviews
- **Character Limits**: Encourage concise yet detailed analysis
- **Rating Integration**: Combine numerical scores with written critique

## API Reference

### Read-Only Functions

```clarity
;; Get viewer profile and cinema statistics
(get-viewer-profile (viewer principal))

;; View movie information and community data
(get-movie (movie-id uint))

;; Check specific watch session details
(get-watch-session (watch-id uint))

;; Read movie reviews and community feedback
(get-movie-review (movie-id uint) (reviewer principal))

;; Verify milestone achievements
(get-milestone (viewer principal) (milestone (string-ascii 12)))
```

### Profile Management

```clarity
;; Check token balance
(get-balance (viewer principal))

;; View token information
(get-name)
(get-symbol)
(get-decimals)
```

## Cinema Milestones

### Available Achievements

| Milestone | Requirement | Reward | Description |
|-----------|-------------|---------|-------------|
| Cinephile-25 | Watch 25 movies | 8.5 MCT | Film enthusiast recognition |
| Critic-12 | Write 12 reviews | 8.5 MCT | Community contribution achievement |

### Future Milestone Ideas
- **Genre Explorer**: Watch films in all available genres
- **Marathon Viewer**: Log 10 movies in a single week
- **Quality Critic**: Receive 100+ upvotes on reviews
- **Classic Curator**: Watch 20+ films from before 1980
- **International Cinema**: Explore films from 10+ countries

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
clarinet test

# Run specific test files
clarinet test tests/movie-database_test.ts
clarinet test tests/watch-logging_test.ts
clarinet test tests/review-system_test.ts

# Validate contract syntax
clarinet check
```

### Test Coverage
- Movie registration and database validation
- Watch session logging with rating tracking
- Review system with upvoting functionality
- Token distribution and reward mechanics
- Milestone achievement verification
- Profile management and customization

## Community Guidelines

### Content Standards
MovieHub promotes a positive and inclusive film community:
- **Respectful Reviews**: Constructive criticism without personal attacks
- **Spoiler Awareness**: Use spoiler-free toggle to protect other viewers
- **Diverse Perspectives**: Welcome different opinions and film interpretations
- **Quality Contributions**: Focus on helpful and insightful content

### Review Best Practices
- Provide specific examples from the film
- Discuss technical aspects like cinematography, acting, direction
- Consider the film's intended audience and genre conventions
- Balance critique with appreciation where appropriate

## Integration Examples

### Movie Streaming App
```javascript
// Integration with streaming platforms
const logStreamingWatch = async (movieData, userRating, notes) => {
  await openContractCall({
    contractAddress: MOVIEHUB_CONTRACT,
    contractName: 'moviehub',
    functionName: 'log-watch',
    functionArgs: [
      uintCV(movieData.id),
      uintCV(userRating),
      stringAsciiCV('streaming'),
      stringAsciiCV(notes)
    ]
  });
};
```

### Mobile Cinema App
```swift
// iOS app for movie tracking
class CinemaTracker {
    func logMovieWatch(movie: Movie, rating: Int, location: String, notes: String) {
        let contractCall = ContractCall(
            function: "log-watch",
            parameters: [movie.id, rating, location, notes]
        )
        stacksService.executeCall(contractCall)
    }
    
    func submitMovieReview(movieId: Int, rating: Int, reviewText: String, spoilerFree: Bool) {
        let contractCall = ContractCall(
            function: "write-review",
            parameters: [movieId, rating, reviewText, spoilerFree]
        )
        stacksService.executeCall(contractCall)
    }
}
```

## Deployment

### Testnet Deployment
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
```bash
clarinet deploy --mainnet
```

### Environment Configuration
```toml
# Clarinet.toml
[contracts.moviehub]
path = "contracts/moviehub.clar"
clarity_version = 2

[network.testnet]
node_rpc_address = "https://stacks-node-api.testnet.stacks.co"
```

## Roadmap

### Phase 1 (Current)
- Core movie database and watch logging
- Basic review system and community features
- Token rewards for cinema activities

### Phase 2 (Q2 2024)
- Advanced movie search and filtering
- Watchlist management and recommendations
- Social features and friend connections

### Phase 3 (Q3 2024)
- Integration with streaming platforms
- Advanced analytics and viewing insights
- Movie discussion forums and threads

### Phase 4 (Q4 2024)
- NFT movie poster collectibles
- Film festival integration and coverage
- Professional critic verification system

## Contributing

We welcome contributions from the film community! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Content Disclaimer

MovieHub is a community platform for film discussion and does not host or distribute copyrighted content. All movie information is for educational and community discussion purposes. Users should respect copyright laws and support content creators through legitimate channels.

## Support

- **Documentation**: [Wiki](https://github.com/yourusername/moviehub-stacks/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/moviehub-stacks/issues)
- **Community**: [Discord](https://discord.gg/moviehub)
- **Film Discussions**: [Forum](https://forum.moviehub.com)

## Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Film and cinema communities for inspiration
- Movie databases and archives for reference
- Film critics and reviewers for quality standards

---

**Lights, camera, blockchain - your cinema journey awaits**
