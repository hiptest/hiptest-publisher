Exporting with Behave
=====================

Exporting as Behave needs a bit of manual fixes to make it work:
 - add a file named __init__.py in the directory where the action words and steps are stored
 - if it is not present yet, add a file "environment.py" in your "features" folder. It has to contain the following lines:

```python
from steps.actionwords import Actionwords

def before_scenario(context, scenario):
    context.actionwords = Actionwords()
```

And that's all, you should be able to use hiptest and behave.