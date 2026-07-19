import re

with open(r'd:\Ky8\PRM393\Code\PRM_project\frontend\lib\models\models.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern to find DateTime.parse(X) and not already followed by .toLocal()
# X can be anything inside parentheses without nested parens for simplicity
content = re.sub(r'(DateTime\.parse\([^)]+\))(?!\.toLocal\(\))', r'\1.toLocal()', content)

with open(r'd:\Ky8\PRM393\Code\PRM_project\frontend\lib\models\models.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced!")
