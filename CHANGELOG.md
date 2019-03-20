# 0.2.0

* Weaken non-critical dependencies (mustache, path, redcarpet) to avoid unnecessary
  integration issues.

* A strategy now yields the block passed at `Client#talktome` with the strategy
  concrete message asset. The Email strategy for instance yields a Mail instance.
  This provides a chance to fix a few details on sending.

# 0.1.0 - A long time ago

Birthday
