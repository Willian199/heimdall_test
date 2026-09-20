abstract class BaseRepository {}

mixin AdvancedAuditable {}

abstract interface class Gateway {}

abstract interface class CompositeRepository extends BaseRepository with AdvancedAuditable implements Gateway {}
