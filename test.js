const body = JSON.stringify({ email: "learner@test.com", password: "123456" });
fetch("http://localhost:5111/api/auth/login", { method: "POST", headers: { "Content-Type": "application/json" }, body })
  .then(res => res.json())
  .then(data => {
    console.log(data);
    const token = data.data.token;
    fetch("http://localhost:5111/api/learning-paths?classId=1", { headers: { "Authorization": "Bearer " + token } })
      .then(res => res.text())
      .then(console.log);
  });
