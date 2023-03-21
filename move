using UnityEngine;

public class Patrol : MonoBehaviour
{
    public Transform[] waypoints;   // 巡邏點的位置
    public float moveSpeed = 2f;    // 移動速度
    public float turnSpeed = 90f;   // 轉向速度
    public float minDistance = 0.1f; // 到達巡邏點的最小距離
    public float evadeDistance = 2f; // 閃避敵人的距離

    private int currentWaypoint = 0; // 目前巡邏點的編號
    private Vector3 direction;      // 移動方向
    private bool isEvading = false; // 是否正在閃避敵人
    private Transform enemy;        // 敵人的位置

    void Start()
    {
        // 設定初始巡邏點
        transform.position = waypoints[currentWaypoint].position;
    }

    void Update()
    {
        // 如果正在閃避敵人，直接返回
        if (isEvading) return;

        // 如果到達目前巡邏點，切換到下一個巡邏點
        if (Vector3.Distance(transform.position, waypoints[currentWaypoint].position) < minDistance)
        {
            currentWaypoint = (currentWaypoint + 1) % waypoints.Length;
        }

        // 計算移動方向
        direction = waypoints[currentWaypoint].position - transform.position;
        direction.y = 0f;
        direction.Normalize();

        // 轉向巡邏點
        transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(direction), turnSpeed * Time.deltaTime);

        // 移動到巡邏點
        transform.position += transform.forward * moveSpeed * Time.deltaTime;
    }

    void OnTriggerEnter(Collider other)
    {
        // 如果碰到敵人，開始閃避
        if (other.CompareTag("Enemy"))
        {
            enemy = other.transform;
            isEvading = true;
            InvokeRepeating("Evade", 0f, 0.5f);
        }
    }

    void Evade()
    {
        // 計算閃避方向
        Vector3 evadeDirection = transform.position - enemy.position;
        evadeDirection.y = 0f;
        evadeDirection.Normalize();

        // 轉向閃避方向
        transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(evadeDirection), turnSpeed * Time.deltaTime);

        // 閃避移動
        transform.position += transform.forward * moveSpeed * Time.deltaTime * 2f;

        // 如果敵人離開閃避範圍，停止閃避
        if (Vector3.Distance(transform.position, enemy.position) > evadeDistance)
        {
            isEvading = false;
            CancelInvoke("Evade");
        }
    }
}
